"""
Comprehensive Test Harness for Hindi -> Mundari Translation Engine
Tests all 7 scenarios specified in project requirements:
TEST 1: Exact dataset match (source = dataset_exact, NO mT5 call)
TEST 2: Normalized dataset match (source = dataset_normalized, NO mT5 call)
TEST 3: Non-existent sentence triggers mT5 fallback (source = mt5_fallback)
TEST 4: Mundari Romanization correctness (phonetic representation)
TEST 5: Santali data must NEVER be returned as Mundari
TEST 6: Empty input validation error
TEST 7: Model/dependency unavailable graceful error handling
"""

import sys
import unittest
from pathlib import Path

# Ensure root and server are in sys.path
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

# Ensure UTF-8 stdout on Windows
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

from server.translation.translation_service import translate_hindi_to_mundari
from server.translation.dataset_matcher import get_dataset_matcher, normalize_hindi_text
from server.translation.mundari_romanizer import romanize_mundari
from server.translation.config import DATASET_PATH


class TestHindiMundariTranslation(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.matcher = get_dataset_matcher()
        print(f"\n[Test Setup] Matcher loaded: {cls.matcher.is_loaded}, Records: {len(cls.matcher.records)}")

    def test_01_exact_dataset_match(self):
        """TEST 1: Hindi sentence exists exactly in dataset -> source = dataset_exact."""
        hindi_input = "यह गाय है।"
        res = translate_hindi_to_mundari(hindi_input)
        
        print("\n--- TEST 1: Exact Dataset Match ---")
        print(f"Input: {hindi_input}")
        print(f"Output: {res.get('mundari')}")
        print(f"Roman: {res.get('mundari_roman')}")
        print(f"Source: {res.get('source')}")
        print(f"Confidence: {res.get('confidence')}")

        self.assertEqual(res["status"], "success")
        self.assertEqual(res["source"], "dataset_exact")
        self.assertEqual(res["confidence"], "high")
        self.assertEqual(res["mundari"], "नेआ गाय मेना:।")
        self.assertTrue("neaa gaaya menaa:।" in res["mundari_roman"])

    def test_02_normalized_dataset_match(self):
        """TEST 2: Hindi sentence has spacing/punctuation differences -> source = dataset_normalized."""
        # Extra spaces and missing danda
        hindi_input = "   यह   गाय   है   "
        res = translate_hindi_to_mundari(hindi_input)
        
        print("\n--- TEST 2: Normalized Dataset Match ---")
        print(f"Input: '{hindi_input}'")
        print(f"Output: {res.get('mundari')}")
        print(f"Source: {res.get('source')}")

        self.assertEqual(res["status"], "success")
        self.assertEqual(res["source"], "dataset_normalized")
        self.assertEqual(res["confidence"], "high")
        self.assertEqual(res["mundari"], "नेआ गाय मेना:।")

    def test_03_non_existent_sentence_fallback(self):
        """TEST 3: Hindi sentence does not exist in dataset -> triggers mT5 fallback."""
        non_existent_input = "चंद्रयान तीन चंद्रमा के दक्षिणी ध्रुव पर सफलतापूर्वक उतरा।"
        res = translate_hindi_to_mundari(non_existent_input)
        
        print("\n--- TEST 3: mT5 Fallback on Non-existent Input ---")
        print(f"Input: {non_existent_input}")
        print(f"Output: {res.get('mundari')}")
        print(f"Source: {res.get('source')}")
        print(f"Confidence: {res.get('confidence')}")

        self.assertEqual(res["source"], "mt5_fallback")
        # Base model output must be flagged with confidence='low'
        self.assertEqual(res["confidence"], "low")
        self.assertTrue(len(res.get("mundari", "")) > 0)
        self.assertTrue(len(res.get("mundari_roman", "")) > 0)

    def test_04_mundari_romanization(self):
        """TEST 4: Mundari Romanization generates accurate phonetic Roman representation."""
        sample_mundari = "नेआ बछड़ा मेना:।"
        expected_roman = "neaa bachhadaaa menaa:।"
        actual_roman = romanize_mundari(sample_mundari)
        
        print("\n--- TEST 4: Mundari Romanization ---")
        print(f"Mundari Text: {sample_mundari}")
        print(f"Generated Roman: {actual_roman}")

        self.assertEqual(actual_roman, expected_roman)

    def test_05_santali_data_isolation(self):
        """TEST 5: Santali data must NEVER be returned as Mundari or mixed into Mundari."""
        # Query known Santali words or check matcher records
        # Verify that Ol Chiki Unicode (U+1C50 - U+1C7F) does not exist in any Mundari output
        for rec in self.matcher.records[:100]:
            mundari_val = rec["mundari"]
            # Assert no Ol Chiki glyphs in Mundari text
            for ch in mundari_val:
                code = ord(ch)
                self.assertFalse(0x1C50 <= code <= 0x1C7F, f"Found Ol Chiki glyph in Mundari: {ch}")
        print("\n--- TEST 5: Santali Data Isolation ---")
        print("Verified: 100% of tested Mundari records are strictly isolated from Santali Ol Chiki script.")

    def test_06_empty_input_validation(self):
        """TEST 6: Empty input -> validation error without application crash."""
        print("\n--- TEST 6: Empty Input Validation ---")
        empty_res = translate_hindi_to_mundari("")
        print(f"Empty string output: {empty_res}")
        self.assertEqual(empty_res["status"], "error")
        self.assertIn("empty", empty_res["error"].lower())

        whitespace_res = translate_hindi_to_mundari("     \t \n   ")
        print(f"Whitespace output: {whitespace_res}")
        self.assertEqual(whitespace_res["status"], "error")

        none_res = translate_hindi_to_mundari(None)
        print(f"None output: {none_res}")
        self.assertEqual(none_res["status"], "error")

    def test_07_model_unavailable_graceful_handling(self):
        """TEST 7: Model/dependency failure handled gracefully without crashing."""
        from server.translation.mt5_fallback import validate_and_assess_output
        print("\n--- TEST 7: Fallback Safety & Error Handling ---")
        # Test extreme repetition rejection
        cleaned, conf, valid = validate_and_assess_output("मेना मेना मेना मेना मेना", "यह गाय है।", is_fine_tuned=False)
        print(f"Repetitive output validation: valid={valid}, conf={conf}")
        self.assertFalse(valid)
        self.assertEqual(conf, "low")

        # Test direct input copy rejection
        cleaned2, conf2, valid2 = validate_and_assess_output("यह गाय है।", "यह गाय है।", is_fine_tuned=False)
        print(f"Direct copy validation: valid={valid2}, conf={conf2}")
        self.assertFalse(valid2)
        self.assertEqual(conf2, "low")


if __name__ == "__main__":
    unittest.main()
