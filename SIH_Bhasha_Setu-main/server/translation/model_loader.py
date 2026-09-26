"""
Model Loader for Hindi -> Mundari Neural Translation
Manages lifecycle of Seq2Seq translation model (MT5ForConditionalGeneration).

Priority:
1. Local fine-tuned Hindi -> Mundari checkpoint (if present)
2. Custom trained checkpoint
3. google/mt5-small fallback architecture
"""

import os
import logging
import threading
from pathlib import Path
from typing import Tuple, Optional, Any

from .config import (
    BASE_MODEL_NAME,
    MODEL_SOURCE,
    FINE_TUNED_CHECKPOINT_PATH,
    HF_CACHE_DIR,
    get_device,
    MT5_MODE
)

logger = logging.getLogger("translation.model_loader")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("[Translation] %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)

class ModelLoader:
    _instance: Optional['ModelLoader'] = None

    def __init__(self):
        self.tokenizer: Optional[Any] = None
        self.model: Optional[Any] = None
        self.device: str = "cpu"
        self.loaded_checkpoint_path: Optional[str] = None
        self.is_fine_tuned: bool = False
        self.load_error: Optional[str] = None
        self._is_downloading: bool = False
        self._lock = threading.Lock()

    @classmethod
    def get_instance(cls) -> 'ModelLoader':
        if cls._instance is None:
            cls._instance = ModelLoader()
        return cls._instance

    def _resolve_checkpoint(self) -> Tuple[str, bool]:
        """
        Determines the checkpoint to load based on hierarchical priority:
        1. Local fine-tuned Hindi -> Mundari checkpoint directory
        2. Configured MODEL_SOURCE
        3. Base google/mt5-small fallback
        """
        # Check if fine-tuned checkpoint exists locally
        if FINE_TUNED_CHECKPOINT_PATH.exists():
            # Check for standard model files
            has_weights = any(
                (FINE_TUNED_CHECKPOINT_PATH / f).exists()
                for f in ["pytorch_model.bin", "model.safetensors", "config.json"]
            )
            if has_weights:
                logger.info(f"Priority 1: Found local fine-tuned Hindi->Mundari checkpoint at {FINE_TUNED_CHECKPOINT_PATH}")
                return str(FINE_TUNED_CHECKPOINT_PATH), True

        # Check configured MODEL_SOURCE
        if MODEL_SOURCE and MODEL_SOURCE != BASE_MODEL_NAME:
            src_path = Path(MODEL_SOURCE)
            if src_path.exists():
                logger.info(f"Priority 2: Loading custom checkpoint from {MODEL_SOURCE}")
                return str(src_path), True
            logger.info(f"Loading custom HF repo from {MODEL_SOURCE}")
            return MODEL_SOURCE, True

        # Fallback to base google/mt5-small
        logger.info(f"Priority 3: Using base {BASE_MODEL_NAME} as translation fallback layer")
        return BASE_MODEL_NAME, False

    def _background_download_and_load(self, checkpoint_path: str):
        """Asynchronously downloads model weights in background without blocking HTTP requests."""
        with self._lock:
            if self.model is not None or self._is_downloading:
                return
            self._is_downloading = True

        try:
            from transformers import AutoModelForSeq2SeqLM
            logger.info(f"Starting background download of {checkpoint_path}...")
            loaded_model = AutoModelForSeq2SeqLM.from_pretrained(
                checkpoint_path,
                cache_dir=str(HF_CACHE_DIR),
                local_files_only=False
            )
            loaded_model.eval()
            loaded_model.to(self.device)
            self.model = loaded_model
            logger.info(f"Background download complete: {checkpoint_path} initialized on {self.device}")
        except Exception as bg_err:
            logger.warning(f"Background download notice: {bg_err}")
        finally:
            self._is_downloading = False

    def load_model(self) -> Tuple[Optional[Any], Optional[Any]]:
        """
        Loads the tokenizer and model into memory once.
        Re-uses the existing in-memory instance on subsequent calls.
        Non-blocking: if weights are not yet cached, initiates background download
        and returns tokenizer immediately with model=None so caller can fall back gracefully.
        """
        if self.model is not None and self.tokenizer is not None:
            return self.tokenizer, self.model

        try:
            import torch
            from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
        except ImportError as e:
            self.load_error = f"Dependencies missing: {e}. Please ensure torch and transformers are installed."
            logger.error(self.load_error)
            return None, None

        self.device = get_device()
        checkpoint_path, is_ft = self._resolve_checkpoint()
        self.is_fine_tuned = is_ft
        self.loaded_checkpoint_path = checkpoint_path

        HF_CACHE_DIR.mkdir(parents=True, exist_ok=True)

        try:
            logger.info(f"Model loading from: {checkpoint_path} on device: {self.device}")
            
            # 1. Load Tokenizer: try local files first to avoid network latency
            if self.tokenizer is None:
                try:
                    self.tokenizer = AutoTokenizer.from_pretrained(
                        checkpoint_path,
                        cache_dir=str(HF_CACHE_DIR),
                        local_files_only=True,
                        use_fast=False
                    )
                except Exception:
                    try:
                        self.tokenizer = AutoTokenizer.from_pretrained(
                            checkpoint_path,
                            cache_dir=str(HF_CACHE_DIR),
                            local_files_only=False,
                            use_fast=False
                        )
                    except Exception as tok_err:
                        logger.warning(f"Tokenizer load notice: {tok_err}")

            # 2. Load Model: try local cached files first
            try:
                self.model = AutoModelForSeq2SeqLM.from_pretrained(
                    checkpoint_path,
                    cache_dir=str(HF_CACHE_DIR),
                    local_files_only=True
                )
                self.model.eval()
                self.model.to(self.device)
                logger.info(f"Model successfully loaded from cache on {self.device}")
                return self.tokenizer, self.model

            except Exception:
                # Weights not cached locally yet
                if os.getenv("MUNDARI_OFFLINE_ONLY", "0") != "1" and not self._is_downloading:
                    thread = threading.Thread(
                        target=self._background_download_and_load,
                        args=(checkpoint_path,),
                        daemon=True
                    )
                    thread.start()
                    logger.info(f"Model weights not yet cached; initiated background download of {checkpoint_path}.")

            return self.tokenizer, None

        except Exception as err:
            self.load_error = f"Model load failure from {checkpoint_path}: {err}"
            logger.warning(self.load_error)
            return self.tokenizer, None


def get_model_and_tokenizer() -> Tuple[Optional[Any], Optional[Any], str, bool]:
    """Helper to retrieve loaded model, tokenizer, device, and fine-tuned status."""
    loader = ModelLoader.get_instance()
    tokenizer, model = loader.load_model()
    return tokenizer, model, loader.device, loader.is_fine_tuned
