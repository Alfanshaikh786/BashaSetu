import 'package:speech_to_text/speech_to_text.dart';

/// Speech Recognition (ASR) Service for Android
/// Wraps Android native SpeechRecognizer with interim token emission
class AsrService {
  static final AsrService instance = AsrService._internal();
  AsrService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  Future<bool> initialize() async {
    if (_isAvailable) return true;
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {},
        onStatus: (val) {},
      );
      return _isAvailable;
    } catch (_) {
      _isAvailable = false;
      return false;
    }
  }

  bool get isListening => _speech.isListening;

  /// Starts real-time listening and streams interim tokens
  Future<void> startListening({
    required String langCode,
    required void Function(String words, bool isFinal, double confidence) onResult,
    required void Function() onSpeechStart,
  }) async {
    final ready = await initialize();
    if (!ready) return;

    String localeId = "en_IN";
    if (langCode == 'hin' || langCode == 'sat' || langCode == 'unr' || langCode == 'hoc') {
      localeId = "hi_IN";
    }

    onSpeechStart();

    await _speech.listen(
      localeId: localeId,
      listenMode: ListenMode.dictation,
      onResult: (result) {
        onResult(
          result.recognizedWords,
          result.finalResult,
          result.confidence,
        );
      },
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
