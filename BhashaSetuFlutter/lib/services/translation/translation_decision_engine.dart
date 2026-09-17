import '../../data/models/translation_result.dart';
import '../../core/utils/ol_chiki_transliteration.dart';
import '../database/database_service.dart';
import '../safety/domain_safety_engine.dart';

/// 4-Tier Translation Decision Engine for Bhasha Setu
/// Provides deterministic, sub-25ms verified offline translation
class TranslationDecisionEngine {
  static final TranslationDecisionEngine instance = TranslationDecisionEngine._internal();
  TranslationDecisionEngine._internal();

  // Tier 1: In-memory fast cache
  final Map<String, TranslationResult> _cache = {};

  /// Resolves translation for given text across language pairs
  Future<TranslationResult> resolveTranslation({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      return TranslationResult.unavailable(
        sourceText: text,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    }

    // Identical languages: return immediately
    if (sourceLang.toLowerCase() == targetLang.toLowerCase()) {
      return TranslationResult(
        sourceText: clean,
        targetText: clean,
        sourceLang: sourceLang,
        targetLang: targetLang,
        reliability: TranslationStatus.verified,
        confidence: 1.0,
        provider: "Identity",
        method: "identity",
        isSuccess: true,
      );
    }

    // Cache key
    final cacheKey = "${sourceLang}_${targetLang}_$clean".toLowerCase();

    // ── Tier 1: In-Memory Cache Lookup (< 5ms) ──
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // ── Tier 2: Native SQLite Database Query (< 15ms) ──
    final dbResult = await DatabaseService.instance.queryTranslation(
      text: clean,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    if (dbResult != null && dbResult['targetText'] != null) {
      final evaluated = DomainSafetyEngine.evaluate(
        sourceText: clean,
        targetText: dbResult['targetText'] as String,
        sourceLang: sourceLang,
        targetLang: targetLang,
        confidence: (dbResult['confidence'] as double?) ?? 0.95,
        method: dbResult['method'] as String? ?? 'sqlite',
        roman: dbResult['roman'] as String?,
        rawRow: dbResult['row'] as Map<String, dynamic>?,
      );

      _cache[cacheKey] = evaluated;

      // Save to local offline history in background
      DatabaseService.instance.saveHistory(
        clean,
        evaluated.targetText,
        sourceLang,
        targetLang,
      ).catchError((_) {});

      return evaluated;
    }

    // ── Tier 3: Transliteration Fallback if Santali (Ol Chiki ↔ Devanagari ↔ Roman) ──
    if (sourceLang == 'sat' && (targetLang == 'hin' || targetLang == 'eng')) {
      if (OlChikiTransliteration.containsOlChiki(clean)) {
        final transliterated = targetLang == 'hin'
            ? OlChikiTransliteration.olChikiToDevanagari(clean)
            : OlChikiTransliteration.olChikiToRoman(clean);

        final result = TranslationResult(
          sourceText: clean,
          targetText: transliterated,
          sourceLang: sourceLang,
          targetLang: targetLang,
          roman: OlChikiTransliteration.olChikiToRoman(clean),
          reliability: TranslationStatus.dataset,
          confidence: 0.90,
          provider: "Ol Chiki Phonetic Engine",
          method: "transliteration",
          isSuccess: true,
        );

        _cache[cacheKey] = result;
        return result;
      }
    }

    // ── Tier 4: Zero-Hallucination Rejection (Refuse to guess) ──
    final rejected = TranslationResult.unavailable(
      sourceText: clean,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    _cache[cacheKey] = rejected;
    return rejected;
  }

  /// Clears in-memory cache
  void clearCache() {
    _cache.clear();
  }
}
