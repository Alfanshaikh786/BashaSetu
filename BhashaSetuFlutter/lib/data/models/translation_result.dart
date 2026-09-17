enum TranslationStatus {
  verified,
  dataset,
  experimental,
  vocabularyOnly,
  unavailable,
}

class TranslationResult {
  final String sourceText;
  final String targetText;
  final String sourceLang;
  final String targetLang;
  final String? roman;
  final TranslationStatus reliability;
  final double confidence;
  final String provider;
  final String method;
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? rawRow;

  const TranslationResult({
    required this.sourceText,
    required this.targetText,
    required this.sourceLang,
    required this.targetLang,
    this.roman,
    required this.reliability,
    required this.confidence,
    required this.provider,
    required this.method,
    required this.isSuccess,
    this.errorMessage,
    this.rawRow,
  });

  factory TranslationResult.unavailable({
    required String sourceText,
    required String sourceLang,
    required String targetLang,
  }) {
    return TranslationResult(
      sourceText: sourceText,
      targetText: "Verified Translation Unavailable",
      sourceLang: sourceLang,
      targetLang: targetLang,
      reliability: TranslationStatus.unavailable,
      confidence: 0.0,
      provider: "Zero-Hallucination Safety Guard",
      method: "safety_rejection",
      isSuccess: false,
      errorMessage: "No verified parallel translation found in curated lexicon.",
    );
  }
}
