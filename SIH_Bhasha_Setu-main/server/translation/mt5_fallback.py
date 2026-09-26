"""
mT5 Fallback Translation Layer
Handles neural sequence-to-sequence translation when no dataset match is found.

Architecture:
- MT5ForConditionalGeneration (google/mt5-small or local fine-tuned checkpoint)
- Configurable prompt prefix instruction
- Controlled beam search generation
- Robust output validation & hallucination safety checks
"""

import re
import logging
from typing import Dict, Any, Optional, Tuple

from .config import TASK_PROMPT_TEMPLATE, GENERATION_CONFIG
from .model_loader import get_model_and_tokenizer

logger = logging.getLogger("translation.mt5_fallback")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("[Translation] %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)

# Known Devanagari Unicode range
DEVANAGARI_RANGE = re.compile(r'[\u0900-\u097F]')
# Latin letters
LATIN_RANGE = re.compile(r'[a-zA-Z]')
# Ol Chiki Unicode range (Santali script - STRICTLY PROHIBITED in Mundari pipeline)
OL_CHIKI_RANGE = re.compile(r'[\u1C50-\u1C7F]')


def validate_and_assess_output(raw_output: str, source_hindi: str, is_fine_tuned: bool) -> Tuple[str, str, bool]:
    """
    Evaluates generated output for quality, repetition, script integrity, and language fidelity.
    Returns: (cleaned_text, confidence, is_valid)
    """
    # Strip mT5 mask/sentinel tokens (e.g. <extra_id_0>, <extra_id_1>)
    cleaned = re.sub(r'<extra_id_\d+>', '', raw_output).strip()

    # 1. Empty output
    if not cleaned:
        return "", "low", False

    # 2. Strict Santali Ol Chiki exclusion
    # Mundari must NEVER use Ol Chiki or Santali script
    if OL_CHIKI_RANGE.search(cleaned):
        logger.warning("Rejected model output: Contained prohibited Ol Chiki (Santali) glyphs.")
        return "", "low", False

    # 3. Direct copy of input
    if cleaned.lower() == source_hindi.strip().lower():
        logger.info("Model output was identical to source Hindi input.")
        return cleaned, "low", False

    # 4. Extreme repetition check (e.g., "क क क क" or "मेना मेना मेना")
    words = cleaned.split()
    if len(words) > 3:
        unique_words = set(words)
        if len(unique_words) / len(words) < 0.35:
            logger.warning("Rejected model output: Degenerate word repetition detected.")
            return cleaned, "low", False

    # 5. Determine confidence level
    # Base google/mt5-small is multilingual pretrained, NOT fine-tuned on Mundari
    # Therefore base outputs are marked with confidence="low"
    confidence = "high" if is_fine_tuned else "low"

    return cleaned, confidence, True


def translate_with_mt5(hindi_text: str) -> Optional[Dict[str, Any]]:
    """
    Translates Hindi text to Mundari using Seq2Seq model generation.
    Returns structured translation metadata.
    """
    if not hindi_text or not hindi_text.strip():
        return None

    tokenizer, model, device, is_fine_tuned = get_model_and_tokenizer()

    if tokenizer is None or model is None:
        logger.error("mT5 model/tokenizer is not available.")
        return None

    try:
        import torch
    except ImportError:
        logger.error("PyTorch is not available for mT5 inference.")
        return None

    # Construct explicit task instruction prompt
    clean_input = hindi_text.strip()
    prompt = TASK_PROMPT_TEMPLATE.format(text=clean_input)

    try:
        inputs = tokenizer(
            prompt,
            return_tensors="pt",
            max_length=128,
            truncation=True,
            padding=False
        ).to(device)

        gen_kwargs = {
            "max_new_tokens": GENERATION_CONFIG.get("max_new_tokens", 128),
            "num_beams": GENERATION_CONFIG.get("num_beams", 4),
            "do_sample": GENERATION_CONFIG.get("do_sample", False),
            "repetition_penalty": GENERATION_CONFIG.get("repetition_penalty", 1.2),
            "length_penalty": GENERATION_CONFIG.get("length_penalty", 1.0),
        }

        # Run inference in eval / no-grad mode
        with torch.inference_mode():
            output_ids = model.generate(**inputs, **gen_kwargs)

        generated_raw = tokenizer.decode(output_ids[0], skip_special_tokens=True)

        cleaned_text, confidence, is_valid = validate_and_assess_output(
            generated_raw,
            clean_input,
            is_fine_tuned
        )

        if not is_valid:
            return {
                "hindi": clean_input,
                "mundari": cleaned_text or clean_input,
                "source": "mt5_fallback",
                "confidence": "low",
                "warning": "Model output flagged for low confidence or raw repetition."
            }

        return {
            "hindi": clean_input,
            "mundari": cleaned_text,
            "source": "mt5_fallback",
            "confidence": confidence
        }

    except Exception as exc:
        logger.error(f"mT5 generation error: {exc}")
        return None
