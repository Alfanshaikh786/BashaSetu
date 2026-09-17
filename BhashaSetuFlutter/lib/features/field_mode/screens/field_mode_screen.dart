import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../services/asr/asr_service.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class FieldModeScreen extends StatefulWidget {
  const FieldModeScreen({super.key});

  @override
  State<FieldModeScreen> createState() => _FieldModeScreenState();
}

class _FieldModeScreenState extends State<FieldModeScreen> {
  String _sourceLang = 'sat';
  String _targetLang = 'hin';
  bool _isListening = false;
  String _spokenText = 'ᱱᱩᱭ ᱫᱚ ᱜᱟᱹᱭ ᱠᱟᱱᱟᱭ ᱾';
  String _translatedText = 'यह गाय है।';
  String _pronunciation = 'Nui do gai kanay.';

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      final tempTxt = _spokenText;
      _spokenText = _translatedText;
      _translatedText = tempTxt;
    });
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await AsrService.instance.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await AsrService.instance.startListening(
        langCode: _sourceLang,
        onSpeechStart: () {},
        onResult: (words, isFinal, conf) async {
          setState(() => _spokenText = words);
          if (isFinal) {
            setState(() => _isListening = false);
            final res = await TranslationDecisionEngine.instance.resolveTranslation(
              text: words,
              sourceLang: _sourceLang,
              targetLang: _targetLang,
            );
            setState(() {
              _translatedText = res.targetText;
              _pronunciation = res.roman ?? '';
            });
            TtsService.instance.speak(text: res.targetText, langCode: _targetLang);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Noise Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text("Acoustic Clarity: Optimal", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ],
                    ),
                    const Text("FIELD MODE (HIGH CONTRAST)", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Language Swap Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_sourceLang == 'sat' ? "Santali (Ol Chiki)" : "Hindi", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded, size: 28, color: AppColors.primary),
                    onPressed: _swapLanguages,
                  ),
                  Text(_targetLang == 'hin' ? "Hindi" : "Santali (Ol Chiki)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 20),

              // Giant Spoken Text Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("SPOKEN PHRASE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Text(
                        _spokenText,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      const Divider(color: AppColors.border, height: 24),
                      const Text("TRANSLATION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      const SizedBox(height: 8),
                      Text(
                        _translatedText,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                      ),
                      if (_pronunciation.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _pronunciation,
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Giant Mic & Action Button (One-Handed Ergonomics)
              SizedBox(
                height: 72,
                child: ElevatedButton.icon(
                  onPressed: _toggleMic,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.red : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, size: 32),
                  label: Text(
                    _isListening ? "Listening... Tap to Translate" : "Speak Now (One-Tap)",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
