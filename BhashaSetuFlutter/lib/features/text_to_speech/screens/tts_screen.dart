import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  String _selectedLang = 'sat';
  final TextEditingController _textController = TextEditingController(
    text: "ᱡᱚᱦᱟᱨ, ᱟᱢᱟᱜ ᱧᱩᱛᱩᱢ ᱪᱮᱫ?",
  );
  double _speechRate = 0.45;
  double _pitch = 1.0;
  bool _isPlaying = false;

  Future<void> _speak() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPlaying = true);
    await TtsService.instance.speak(
      text: text,
      langCode: _selectedLang,
      rate: _speechRate,
      pitch: _pitch,
    );
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _stop() async {
    await TtsService.instance.stop();
    setState(() => _isPlaying = false);
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
                  child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Text-to-Speech (TTS)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text("Phonetic voice synthesis for indigenous scripts", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TARGET TEXT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      DropdownButton<String>(
                        value: _selectedLang,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'sat', child: Text("Santali (Ol Chiki)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'hin', child: Text("Hindi", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'eng', child: Text("English", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLang = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _textController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: "Enter sentence to synthesize...",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sliders
                  Text("Speech Rate (${_speechRate.toStringAsFixed(2)}x)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  Slider(
                    value: _speechRate,
                    min: 0.2,
                    max: 1.0,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _speechRate = val),
                  ),

                  Text("Pitch (${_pitch.toStringAsFixed(2)})", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 1.5,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _pitch = val),
                  ),
                  const SizedBox(height: 16),

                  // Control Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _speak,
                          icon: Icon(_isPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded),
                          label: Text(_isPlaying ? "Speaking..." : "Synthesize & Speak"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _stop,
                        child: const Text("Stop"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
