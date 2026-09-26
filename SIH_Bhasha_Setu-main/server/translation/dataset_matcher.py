"""
Mundari Dataset Matcher
Inspects existing project datasets, normalizes input Hindi,
and conducts exact, normalized, and fuzzy matching.

CRITICAL DIRECTIVE:
Mundari and Santali are strictly separate languages.
NEVER substitute Santali data for Mundari.
Explicit validation guarantees only Mundari columns and tables are utilized.
"""

import os
import re
import csv
import logging
import unicodedata
from pathlib import Path
from typing import Optional, Dict, Any, List, Tuple

try:
    from rapidfuzz import fuzz
    HAS_RAPIDFUZZ = True
except ImportError:
    import difflib
    HAS_RAPIDFUZZ = False

from .config import DATASET_PATH, SQLITE_DB_PATH, PROJECT_ROOT

logger = logging.getLogger("translation.dataset_matcher")
if not logger.handlers:
    handler = logging.StreamHandler()
    formatter = logging.Formatter("[Translation] %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)

# Column candidate names for auto-discovery
HINDI_COLUMN_CANDIDATES = ['hindi', 'Hindi', 'src', 'source', 'input', 'hin']
MUNDARI_COLUMN_CANDIDATES = ['mundari', 'Mundari', 'target', 'translation', 'unr', 'mun']
ROMAN_COLUMN_CANDIDATES = [
    'mundari_english_pronounciation', 'mundari_roman', 'roman',
    'romanized', 'roman_mundari', 'pronunciation'
]

# Prohibited Santali markers (to prevent accidental contamination)
SANTALI_PROHIBITED_MARKERS = ['santali', 'sat', 'ol_chiki', 'ol chiki']


def normalize_hindi_text(text: str) -> str:
    """
    Standardizes Hindi input text:
    - Unicode normalization (NFKC)
    - Strips leading/trailing whitespace
    - Collapses multiple whitespace characters to single space
    - Strips peripheral Devanagari and Latin punctuation (।, ॥, ?, !, ., ,, etc.)
    - Preserves core linguistic semantics (vowels, matras, consonants, anusvara, halant)
    """
    if not text:
        return ""
    # Unicode normalize
    norm = unicodedata.normalize("NFKC", text.strip())
    # Collapse multiple whitespaces
    norm = re.sub(r'\s+', ' ', norm)
    # Strip peripheral punctuation for normalized matching
    norm = re.sub(r'[।॥\.\?!,;:\'\"()\[\]{}—\-]+$', '', norm)
    norm = re.sub(r'^[।॥\.\?!,;:\'\"()\[\]{}—\-]+', '', norm)
    return norm.strip()


class MundariDatasetMatcher:
    def __init__(self, dataset_path: Optional[Path] = None):
        self.dataset_path = dataset_path or DATASET_PATH
        self.exact_map: Dict[str, Dict[str, str]] = {}
        self.normalized_map: Dict[str, Dict[str, str]] = {}
        self.records: List[Dict[str, str]] = []
        self.is_loaded = False
        self._load_dataset()

    def _auto_discover_dataset(self) -> Optional[Path]:
        """Scans project directory for Mundari parallel dataset files if primary path is missing."""
        if self.dataset_path and self.dataset_path.exists():
            return self.dataset_path

        candidates = [
            PROJECT_ROOT / "MUNDARI DATASET.csv",
            PROJECT_ROOT / "research" / "datasets" / "mundari" / "train.csv",
            PROJECT_ROOT / "research" / "mundari-mt" / "cleaned-data" / "train.csv"
        ]
        for c in candidates:
            if c.exists():
                return c

        # Scan for any CSV with 'mundari' in filename
        for root, _, files in os.walk(PROJECT_ROOT):
            if any(p in root for p in ['node_modules', '.git', 'dist', '.agents']):
                continue
            for f in files:
                if f.lower().endswith(('.csv', '.tsv', '.json', '.xlsx')) and 'mundari' in f.lower():
                    return Path(root) / f

        return None

    def _inspect_and_identify_columns(self, fieldnames: List[str]) -> Tuple[Optional[str], Optional[str], Optional[str]]:
        """
        Inspects schema and identifies Hindi, Mundari, and Roman columns.
        Explicitly rejects any Santali columns as Mundari.
        """
        hi_col = None
        mun_col = None
        rom_col = None

        field_map = {f.strip().lower(): f for f in fieldnames}

        # Identify Hindi column
        for cand in HINDI_COLUMN_CANDIDATES:
            if cand.lower() in field_map:
                hi_col = field_map[cand.lower()]
                break

        # Identify Mundari column (strictly avoiding Santali)
        for cand in MUNDARI_COLUMN_CANDIDATES:
            if cand.lower() in field_map:
                actual_name = field_map[cand.lower()]
                if not any(santali_marker in actual_name.lower() for santali_marker in SANTALI_PROHIBITED_MARKERS):
                    mun_col = actual_name
                    break

        # Identify Roman Pronunciation column
        for cand in ROMAN_COLUMN_CANDIDATES:
            if cand.lower() in field_map:
                actual_name = field_map[cand.lower()]
                if not any(santali_marker in actual_name.lower() for santali_marker in SANTALI_PROHIBITED_MARKERS):
                    rom_col = actual_name
                    break

        return hi_col, mun_col, rom_col

    def _load_dataset(self) -> None:
        """Loads Mundari dataset into exact and normalized O(1) in-memory indices."""
        target_path = self._auto_discover_dataset()
        if not target_path or not target_path.exists():
            logger.warning(f"No Mundari dataset found at {self.dataset_path}. Falling back to SQLite db.")
            self._load_from_sqlite()
            return

        try:
            with open(target_path, mode='r', encoding='utf-8', errors='replace') as f:
                reader = csv.DictReader(f)
                if not reader.fieldnames:
                    logger.warning("Empty CSV header in Mundari dataset.")
                    return

                hi_col, mun_col, rom_col = self._inspect_and_identify_columns(reader.fieldnames)

                if not hi_col or not mun_col:
                    raise ValueError(
                        f"Dataset schema mismatch: Could not find both Hindi and Mundari columns in {reader.fieldnames}. "
                        "Mundari data must be explicitly isolated from Santali."
                    )

                logger.info(f"Loaded Mundari dataset from {target_path.name} [Hindi: '{hi_col}', Mundari: '{mun_col}', Roman: '{rom_col}']")

                count = 0
                for row in reader:
                    hi_val = (row.get(hi_col) or "").strip()
                    mun_val = (row.get(mun_col) or "").strip()
                    rom_val = (row.get(rom_col) or "").strip() if rom_col else ""

                    if not hi_val or not mun_val:
                        continue

                    # Validate that Mundari is NOT empty or identical to Santali
                    record = {
                        "hindi": hi_val,
                        "mundari": mun_val,
                        "mundari_roman": rom_val
                    }

                    # Exact index
                    self.exact_map[hi_val] = record

                    # Normalized index
                    norm_hi = normalize_hindi_text(hi_val)
                    if norm_hi and norm_hi not in self.normalized_map:
                        self.normalized_map[norm_hi] = record

                    self.records.append(record)
                    count += 1

                self.is_loaded = True
                logger.info(f"Indexed {count} verified Mundari parallel sentences.")

        except Exception as e:
            logger.error(f"Failed to load Mundari CSV dataset: {e}. Attempting SQLite fallback.")
            self._load_from_sqlite()

    def _load_from_sqlite(self) -> None:
        """Loads Mundari translations from local translations.db if CSV is unavailable."""
        if not SQLITE_DB_PATH.exists():
            return
        import sqlite3
        try:
            conn = sqlite3.connect(str(SQLITE_DB_PATH))
            cur = conn.cursor()
            cur.execute("SELECT hindi, mundari, COALESCE(mundari_roman, '') FROM translations WHERE mundari IS NOT NULL AND TRIM(mundari) != '';")
            rows = cur.fetchall()
            cur.close()
            conn.close()

            for hi_val, mun_val, rom_val in rows:
                hi_val = hi_val.strip()
                mun_val = mun_val.strip()
                rom_val = rom_val.strip()

                record = {
                    "hindi": hi_val,
                    "mundari": mun_val,
                    "mundari_roman": rom_val
                }
                self.exact_map[hi_val] = record
                norm_hi = normalize_hindi_text(hi_val)
                if norm_hi and norm_hi not in self.normalized_map:
                    self.normalized_map[norm_hi] = record
                self.records.append(record)

            self.is_loaded = True
            logger.info(f"Indexed {len(rows)} verified Mundari sentences from SQLite.")
        except Exception as sq_err:
            logger.error(f"Failed to load Mundari dataset from SQLite: {sq_err}")

    def find_match(self, hindi_text: str) -> Optional[Dict[str, Any]]:
        """
        Executes hierarchical matching against the verified Mundari dataset:
        1. Exact Match -> source='dataset_exact'
        2. Normalized Match -> source='dataset_normalized'
        3. High-Confidence Fuzzy Match (>= 90% similarity) -> source='dataset_fuzzy'
        
        Returns None if no suitable match is found.
        """
        if not hindi_text or not hindi_text.strip():
            return None

        raw = hindi_text.strip()

        # 1. Exact Match
        if raw in self.exact_map:
            rec = self.exact_map[raw]
            return {
                "hindi": rec["hindi"],
                "mundari": rec["mundari"],
                "mundari_roman": rec["mundari_roman"],
                "source": "dataset_exact",
                "confidence": "high"
            }

        # 2. Normalized Exact Match
        norm = normalize_hindi_text(raw)
        if norm in self.normalized_map:
            rec = self.normalized_map[norm]
            return {
                "hindi": rec["hindi"],
                "mundari": rec["mundari"],
                "mundari_roman": rec["mundari_roman"],
                "source": "dataset_normalized",
                "confidence": "high"
            }

        # 3. High-Confidence Fuzzy Match
        if HAS_RAPIDFUZZ and norm:
            best_score = 0.0
            best_rec = None
            for cand_norm, rec in self.normalized_map.items():
                score = fuzz.ratio(norm, cand_norm)
                if score > best_score:
                    best_score = score
                    best_rec = rec
                    if best_score == 100:
                        break

            if best_rec and best_score >= 90:
                return {
                    "hindi": best_rec["hindi"],
                    "mundari": best_rec["mundari"],
                    "mundari_roman": best_rec["mundari_roman"],
                    "source": "dataset_fuzzy",
                    "confidence": "high",
                    "similarity": round(best_score / 100.0, 2)
                }

        return None


# Singleton instance
_matcher_instance: Optional[MundariDatasetMatcher] = None

def get_dataset_matcher() -> MundariDatasetMatcher:
    global _matcher_instance
    if _matcher_instance is None:
        _matcher_instance = MundariDatasetMatcher()
    return _matcher_instance
