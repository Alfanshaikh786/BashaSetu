import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../data/models/translation_result.dart';
import '../translation/translation_decision_engine.dart';

/// Neural Document OCR Engine for Android
/// Replicates React ocrService.ts with on-device text recognition and instant translation
class OcrService {
  static final OcrService instance = OcrService._internal();
  OcrService._internal();

  TextRecognizer? _recognizerLatin;
  TextRecognizer? _recognizerDevanagari;

  void _ensureInitialized() {
    _recognizerLatin ??= TextRecognizer(script: TextRecognitionScript.latin);
    _recognizerDevanagari ??= TextRecognizer(script: TextRecognitionScript.devanagiri);
  }

  /// Recognizes text from image file and translates it
  Future<Map<String, dynamic>> processImageAndTranslate({
    required File imageFile,
    required String sourceLang,
    required String targetLang,
  }) async {
    _ensureInitialized();

    final inputImage = InputImage.fromFile(imageFile);

    // Select script engine based on source language
    final recognizer = (sourceLang == 'hin' || sourceLang == 'unr')
        ? _recognizerDevanagari!
        : _recognizerLatin!;

    final recognizedText = await recognizer.processImage(inputImage);
    final rawText = recognizedText.text.trim();

    if (rawText.isEmpty) {
      return {
        'extractedText': '',
        'translatedText': 'No legible text detected in document image.',
        'confidence': 0.0,
        'translation': TranslationResult.unavailable(
          sourceText: '',
          sourceLang: sourceLang,
          targetLang: targetLang,
        ),
      };
    }

    // Resolve translation via 4-tier decision engine
    final translation = await TranslationDecisionEngine.instance.resolveTranslation(
      text: rawText,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    return {
      'extractedText': rawText,
      'translatedText': translation.targetText,
      'confidence': translation.confidence,
      'translation': translation,
      'blocksCount': recognizedText.blocks.length,
    };
  }

  void dispose() {
    _recognizerLatin?.close();
    _recognizerDevanagari?.close();
    _recognizerLatin = null;
    _recognizerDevanagari = null;
  }
}
