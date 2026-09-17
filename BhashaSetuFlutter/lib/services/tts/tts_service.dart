import 'package:flutter_tts/flutter_tts.dart';
import '../../core/utils/ol_chiki_transliteration.dart';

/// Neural & Phonetic TTS Synthesis Engine
/// Replicates React ttsEngine.ts with Indian phonetic bridge for indigenous scripts
class TtsService {
  static final TtsService instance = TtsService._internal();
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;
    _flutterTts = FlutterTts();

    await _flutterTts!.setSpeechRate(0.45); // Natural, clear classroom speed
    await _flutterTts!.setPitch(1.0);
    await _flutterTts!.setVolume(1.0);

    _isInitialized = true;
  }

  /// Speaks text using language code with phonetic acoustic bridge
  Future<void> speak({
    required String text,
    required String langCode,
    double rate = 0.45,
    double pitch = 1.0,
  }) async {
    await _init();
    final clean = text.trim();
    if (clean.isEmpty) return;

    await _flutterTts!.stop();
    await _flutterTts!.setSpeechRate(rate);
    await _flutterTts!.setPitch(pitch);

    // Phonetic bridge strategy
    switch (langCode.toLowerCase()) {
      case 'sat': // Santali
        if (OlChikiTransliteration.containsOlChiki(clean)) {
          // Bridge Ol Chiki through Devanagari acoustic phonetics
          final phoneticHindi = OlChikiTransliteration.olChikiToDevanagari(clean);
          await _flutterTts!.setLanguage("hi-IN");
          await _flutterTts!.speak(phoneticHindi);
        } else {
          // Roman phonetic Santali
          await _flutterTts!.setLanguage("hi-IN");
          await _flutterTts!.speak(clean);
        }
        break;

      case 'unr': // Mundari
      case 'hoc': // Ho
      case 'hin': // Hindi
        await _flutterTts!.setLanguage("hi-IN");
        await _flutterTts!.speak(clean);
        break;

      case 'eng': // English
      default:
        await _flutterTts!.setLanguage("en-IN");
        await _flutterTts!.speak(clean);
        break;
    }
  }

  Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
  }
}
