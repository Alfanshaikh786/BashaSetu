import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../services/asr/asr_service.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../data/models/translation_result.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  String _selectedLang = 'hin';
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  TranslationResult? _translationResult;
  bool _isTranslating = false;

  Future<void> _toggleListening() async {
    if (_isListening) {
      await AsrService.instance.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _translationResult = null;
      });

      await AsrService.instance.startListening(
        langCode: _selectedLang,
        onSpeechStart: () {},
        onResult: (words, isFinal, conf) {
          setState(() {
            _recognizedText = words;
            _confidence = conf;
            if (isFinal) {
              _isListening = false;
              _translateRecognizedText(words);
            }
          });
        },
      );
    }
  }

  Future<void> _translateRecognizedText(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isTranslating = true);

    final targetLang = _selectedLang == 'sat' ? 'hin' : 'sat';
    final res = await TranslationDecisionEngine.instance.resolveTranslation(
      text: text,
      sourceLang: _selectedLang,
      targetLang: targetLang,
    );

    setState(() {
      _translationResult = res;
      _isTranslating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Speech-to-Text (ASR)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text("Live streaming phonetic transcription", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Microphone Big Toggle Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: _toggleListening,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? Colors.red : AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : AppColors.primary).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isListening ? "Listening... Speak now" : "Tap microphone to dictate",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isListening ? Colors.red : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Language: ${_selectedLang == 'hin' ? 'Hindi' : 'Santali'}",
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transcription Result Card
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TRANSCRIPTION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _recognizedText));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied transcription!")));
                          },
                        ),
                      ],
                    ),
                    Text(
                      _recognizedText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],

            // Auto-Translation Card
            if (_translationResult != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TRANSLATION (VERIFIED)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const SizedBox(height: 8),
                    Text(
                      _translationResult!.targetText,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                    if (_translationResult!.roman != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _translationResult!.roman!,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
