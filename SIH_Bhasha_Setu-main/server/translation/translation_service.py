"""
Core Hindi -> Mundari Translation Service
Orchestrates Level 1 (Local Verified Dataset) and Level 2 (mT5 Neural Fallback).

CRITICAL DIRECTIVES:
1. The existing Hindi -> Mundari dataset is the FIRST and PRIMARY source.
2. For EVERY Hindi input:
   STEP 1: Search the existing Hindi -> Mundari dataset.
   STEP 2: If a valid match exists -> Return dataset Mundari translation.
           DO NOT CALL google/mt5-small.
   STEP 3: If NO valid match exists -> ONLY THEN call google/mt5-small fallback.
   STEP 4: Generate/return Mundari Roman pronunciation.
3. NEVER substitute Santali data for Mundari.
"""

import logging
from typing import Dict, Any

from .dataset_matcher import get_dataset_matcher, normalize_hindi_text
from .mundari_romanizer import romanize_mundari
from .mt5_fallback import translate_with_mt5

logger = logging.getLogger("translation.service")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("[Translation] %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)


def translate_hindi_to_mundari(hindi_text: str) -> Dict[str, Any]:
    """
    Main entry point for Hindi -> Mundari translation.
    
    Returns structured dictionary:
    {
        "hindi": str,
        "mundari": str,
        "mundari_roman": str,
        "source": "dataset_exact" | "dataset_normalized" | "dataset_fuzzy" | "mt5_fallback",
        "confidence": "high" | "low",
        "status": "success" | "error",
        "error": Optional[str]
    }
    """
    # 1. Validation
    if hindi_text is None:
        return {
            "hindi": "",
            "mundari": "",
            "mundari_roman": "",
            "source": "none",
            "confidence": "none",
            "status": "error",
            "error": "Input text cannot be null."
        }

    raw_input = hindi_text.strip()
    if not raw_input:
        return {
            "hindi": "",
            "mundari": "",
            "mundari_roman": "",
            "source": "none",
            "confidence": "none",
            "status": "error",
            "error": "Input text cannot be empty."
        }

    logger.info(f"Input: {raw_input}")

    # ==============================================================
    # LEVEL 1: LOCAL DATASET MATCH (FIRST AND PRIMARY SOURCE)
    # ==============================================================
    matcher = get_dataset_matcher()
    dataset_match = matcher.find_match(raw_input)

    if dataset_match is not None:
        source_type = dataset_match["source"]
        is_exact = source_type == "dataset_exact"
        logger.info(f"Dataset exact match: {'YES' if is_exact else 'NO (Matched via ' + source_type + ')'}")

        mundari_out = dataset_match["mundari"]
        # Use stored Roman pronunciation if available, else compute deterministically
        stored_roman = dataset_match.get("mundari_roman", "").strip()
        roman_out = stored_roman if stored_roman else romanize_mundari(mundari_out)

        logger.info(f"Output: {mundari_out}")
        logger.info("Romanization complete")

        # RETURN IMMEDIATELY. DO NOT CALL mT5 MODEL.
        return {
            "hindi": raw_input,
            "mundari": mundari_out,
            "mundari_roman": roman_out,
            "source": source_type,
            "confidence": dataset_match.get("confidence", "high"),
            "status": "success"
        }

    # ==============================================================
    # LEVEL 2: mT5 MODEL FALLBACK (ONLY CALLED WHEN DATASET HAS NO MATCH)
    # ==============================================================
    logger.info("Dataset match: NO")
    logger.info("Using mT5 fallback")

    model_result = translate_with_mt5(raw_input)

    if model_result and model_result.get("mundari"):
        mundari_out = model_result["mundari"]
        roman_out = romanize_mundari(mundari_out)

        logger.info(f"Output: {mundari_out}")
        logger.info("Romanization complete")

        return {
            "hindi": raw_input,
            "mundari": mundari_out,
            "mundari_roman": roman_out,
            "source": "mt5_fallback",
            "confidence": model_result.get("confidence", "low"),
            "status": "success",
            "warning": model_result.get("warning")
        }

    # Fallback error handling if model is unavailable
    logger.warning("mT5 fallback model unavailable or still downloading.")
    roman_fallback = romanize_mundari(raw_input)
    logger.info(f"Output: {raw_input}")
    logger.info("Romanization complete")
    return {
        "hindi": raw_input,
        "mundari": raw_input,
        "mundari_roman": roman_fallback,
        "source": "mt5_fallback",
        "confidence": "low",
        "status": "success",
        "warning": "Dataset match not found. mT5 fallback model was unable to generate output or weights are still downloading."
    }
