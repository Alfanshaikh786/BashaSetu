"""
Configuration for Hindi -> Mundari Translation Engine
Supports Level 1 (Local Verified Dataset) and Level 2 (mT5 Fallback / Fine-Tuned Checkpoint).
"""

import os
from pathlib import Path

# Paths
SERVER_DIR = Path(__file__).resolve().parent.parent
PROJECT_ROOT = SERVER_DIR.parent

# Dataset Configuration
# Auto-detect existing Mundari dataset with fallback options
DEFAULT_DATASET_PATH = PROJECT_ROOT / "MUNDARI DATASET.csv"
DATASET_PATH = Path(os.getenv("MUNDARI_DATASET_PATH", str(DEFAULT_DATASET_PATH)))

# Fallback SQLite DB
SQLITE_DB_PATH = PROJECT_ROOT / "translations.db"

# Model Configuration
# Priority:
# 1. Local fine-tuned Hindi -> Mundari checkpoint if present
# 2. Existing trained translation model
# 3. Base google/mt5-small fallback
DEFAULT_FINE_TUNED_PATH = PROJECT_ROOT / "models" / "mt5-hindi-mundari"
FINE_TUNED_CHECKPOINT_PATH = Path(os.getenv("MUNDARI_FINETUNED_PATH", str(DEFAULT_FINE_TUNED_PATH)))

BASE_MODEL_NAME = "google/mt5-small"
MODEL_SOURCE = os.getenv("MUNDARI_MODEL_SOURCE", BASE_MODEL_NAME)

# Operating Mode: 'fallback' for base pre-trained mT5, 'fine_tuned' for supervised checkpoint
MT5_MODE = os.getenv("MUNDARI_MT5_MODE", "fallback")

# Configurable Prompt Format for Seq2Seq Generation
# Easily configurable without changing application logic
TASK_PROMPT_TEMPLATE = os.getenv(
    "MUNDARI_PROMPT_TEMPLATE",
    "translate Hindi to Mundari: {text}"
)

# Generation Hyperparameters
GENERATION_CONFIG = {
    "max_new_tokens": int(os.getenv("MUNDARI_MAX_NEW_TOKENS", "48")),
    "num_beams": int(os.getenv("MUNDARI_NUM_BEAMS", "1")),
    "do_sample": False,
    "temperature": float(os.getenv("MUNDARI_TEMPERATURE", "1.0")),
    "repetition_penalty": float(os.getenv("MUNDARI_REPETITION_PENALTY", "1.2")),
    "length_penalty": float(os.getenv("MUNDARI_LENGTH_PENALTY", "1.0")),
}

# Cache Directory (avoid re-downloading model on every restart)
HF_CACHE_DIR = Path(os.getenv("HF_HOME", str(PROJECT_ROOT / ".cache" / "huggingface")))

# Device Configuration: auto-detect CUDA if available, fallback to CPU
def get_device():
    try:
        import torch
        if torch.cuda.is_available():
            return "cuda"
    except ImportError:
        pass
    return "cpu"

DEVICE = get_device()
