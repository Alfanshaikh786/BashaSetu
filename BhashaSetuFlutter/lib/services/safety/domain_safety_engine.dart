import '../../data/models/translation_result.dart';

/// Domain Safety Engine for Bhasha Setu
/// Enforces the strict "Never Guess" zero-hallucination policy
class DomainSafetyEngine {
  static const List<String> criticalMedicalTerms = [
    'snakebite',
    'poison',
    'fever',
    'bleeding',
    'breathing',
    'heart',
    'unconscious',
    'ambulance',
    'hospital',
    'medicine',
    'dose',
    'सांप',
    'जहर',
    'बुखार',
    'खून',
    'सांस',
    'दवा',
    'ᱵᱤᱧ',
    'ᱨᱟᱱ',
    'ᱨᱩᱣᱟᱹ',
    'ᱢᱟᱭᱟᱢ'
  ];

  /// Validates a potential translation candidate against safety guidelines
  static TranslationResult evaluate({
    required String sourceText,
    required String? targetText,
    required String sourceLang,
    required String targetLang,
    required double confidence,
    required String method,
    String? roman,
    Map<String, dynamic>? rawRow,
  }) {
    final cleanSource = sourceText.trim();

    // 1. If target text is null, empty, or whitespace, return Verified Translation Unavailable
    if (targetText == null || targetText.trim().isEmpty) {
      return TranslationResult.unavailable(
        sourceText: cleanSource,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    }

    final cleanTarget = targetText.trim();

    // 2. Check for critical medical/emergency domain
    final isMedicalContext = criticalMedicalTerms.any(
      (term) => cleanSource.toLowerCase().contains(term) || cleanTarget.toLowerCase().contains(term),
    );

    // For critical medical phrases, demand strict verification (confidence >= 0.90)
    if (isMedicalContext && confidence < 0.90) {
      return TranslationResult.unavailable(
        sourceText: cleanSource,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    }

    // 3. Determine transparent reliability tier
    TranslationStatus status;
    if (confidence >= 0.98) {
      status = TranslationStatus.verified;
    } else if (confidence >= 0.90) {
      status = TranslationStatus.dataset;
    } else if (confidence >= 0.70) {
      status = TranslationStatus.experimental;
    } else {
      status = TranslationStatus.vocabularyOnly;
    }

    return TranslationResult(
      sourceText: cleanSource,
      targetText: cleanTarget,
      sourceLang: sourceLang,
      targetLang: targetLang,
      roman: roman,
      reliability: status,
      confidence: confidence,
      provider: method == 'exact_sqlite_match'
          ? 'Verified Tribal SQLite Corpus'
          : 'Curated Linguistic Engine',
      method: method,
      isSuccess: true,
      rawRow: rawRow,
    );
  }
}
