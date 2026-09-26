"""
Hindi -> Mundari Translation Engine Package
Provides hierarchical translation:
- Level 1: Verified Local Mundari Dataset
- Level 2: mT5 Neural Fallback
"""

from .translation_service import translate_hindi_to_mundari
from .dataset_matcher import get_dataset_matcher, normalize_hindi_text
from .mundari_romanizer import romanize_mundari
from .mt5_fallback import translate_with_mt5
from .model_loader import get_model_and_tokenizer
from .config import DATASET_PATH, MODEL_SOURCE, MT5_MODE, TASK_PROMPT_TEMPLATE

__all__ = [
    "translate_hindi_to_mundari",
    "get_dataset_matcher",
    "normalize_hindi_text",
    "romanize_mundari",
    "translate_with_mt5",
    "get_model_and_tokenizer",
    "DATASET_PATH",
    "MODEL_SOURCE",
    "MT5_MODE",
    "TASK_PROMPT_TEMPLATE"
]
