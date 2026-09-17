import 'package:flutter_test/flutter_test.dart';
import 'package:bhasha_setu_flutter/services/safety/domain_safety_engine.dart';
import 'package:bhasha_setu_flutter/data/models/translation_result.dart';

void main() {
  group('Zero-Hallucination Domain Safety Engine Tests', () {
    test('Rejects missing translation with Verified Translation Unavailable', () {
      final res = DomainSafetyEngine.evaluate(
        sourceText: "Unknown tribal phrase",
        targetText: "",
        sourceLang: "sat",
        targetLang: "hin",
        confidence: 0.0,
        method: "none",
      );

      expect(res.isSuccess, isFalse);
      expect(res.targetText, "Verified Translation Unavailable");
      expect(res.reliability, TranslationStatus.unavailable);
    });

    test('Rejects low-confidence medical emergency phrase', () {
      final res = DomainSafetyEngine.evaluate(
        sourceText: "Snakebite emergency poison dosage",
        targetText: "Hypothetical translation guess",
        sourceLang: "eng",
        targetLang: "sat",
        confidence: 0.65, // Below strict 0.90 safety threshold
        method: "experimental",
      );

      expect(res.isSuccess, isFalse);
      expect(res.targetText, "Verified Translation Unavailable");
    });

    test('Accepts verified high-confidence phrase', () {
      final res = DomainSafetyEngine.evaluate(
        sourceText: "Where is the school?",
        targetText: "ᱢᱟᱬᱟᱝ ᱟᱥᱲᱟ ᱫᱚ ᱚᱠᱟᱨᱮ ᱢᱮᱱᱟᱜ-ᱟ?",
        sourceLang: "eng",
        targetLang: "sat",
        confidence: 0.99,
        method: "exact_sqlite_match",
      );

      expect(res.isSuccess, isTrue);
      expect(res.reliability, TranslationStatus.verified);
      expect(res.targetText, "ᱢᱟᱬᱟᱝ ᱟᱥᱲᱟ ᱫᱚ ᱚᱠᱟᱨᱮ ᱢᱮᱱᱟᱜ-ᱟ?");
    });
  });
}
