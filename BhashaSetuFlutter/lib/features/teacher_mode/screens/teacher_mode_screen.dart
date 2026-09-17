import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../services/asr/asr_service.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class TeacherModeScreen extends StatefulWidget {
  const TeacherModeScreen({super.key});

  @override
  State<TeacherModeScreen> createState() => _TeacherModeScreenState();
}

class _TeacherModeScreenState extends State<TeacherModeScreen> {
  bool _isLessonActive = false;
  int _lessonSeconds = 0;
  Timer? _clockTimer;

  String _liveSpoken = "आज हम गणित और पहाड़ों के बारे में पढ़ेंगे।";
  String _liveTranslation = "ᱛᱮᱦᱮᱧ ᱫᱚ ᱮᱞᱠᱷᱟ ᱟᱨ ᱵᱩᱨᱩ ᱠᱚ ᱵᱟᱵᱚᱛ ᱵᱚᱱ ᱯᱟᱲᱦᱟᱣ-ᱟ ᱾";

  final List<Map<String, String>> _extractedVocab = [
    {'sat': 'ᱮᱞᱠᱷᱟ', 'roman': 'Elkha', 'hi': 'गणित', 'en': 'Mathematics'},
    {'sat': 'ᱵᱩᱨᱩ', 'roman': 'Buru', 'hi': 'पहाड़', 'en': 'Mountain'},
    {'sat': 'ᱯᱟᱲᱦᱟᱣ', 'roman': 'Parhao', 'hi': 'पढ़ना', 'en': 'Study / Read'},
  ];

  void _toggleLesson() {
    setState(() {
      _isLessonActive = !_isLessonActive;
      if (_isLessonActive) {
        _lessonSeconds = 0;
        _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() => _lessonSeconds++);
        });
        _startTeacherAsr();
      } else {
        _clockTimer?.cancel();
        AsrService.instance.stopListening();
      }
    });
  }

  void _startTeacherAsr() {
    AsrService.instance.startListening(
      langCode: 'hin',
      onSpeechStart: () {},
      onResult: (words, isFinal, conf) async {
        setState(() => _liveSpoken = words);
        if (isFinal) {
          final res = await TranslationDecisionEngine.instance.resolveTranslation(
            text: words,
            sourceLang: 'hin',
            targetLang: 'sat',
          );
          setState(() => _liveTranslation = res.targetText);
        }
      },
    );
  }

  String _formatTimer(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Projector Mode
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Projector Status Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isLessonActive ? Colors.red : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isLessonActive ? "LIVE PROJECTOR STREAM" : "PROJECTOR STANDBY",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Duration: ${_formatTimer(_lessonSeconds)}",
                        style: const TextStyle(fontSize: 14, color: Colors.white70, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _toggleLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLessonActive ? Colors.red : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(_isLessonActive ? Icons.stop_rounded : Icons.play_arrow_rounded),
                    label: Text(_isLessonActive ? "End Lesson" : "Start Projector Lesson"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Giant Dual-Script Projector Subtitles
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade950,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey.shade800, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "TEACHER SPOKEN (HINDI)",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _liveSpoken,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: Colors.grey, height: 1),
                      const SizedBox(height: 32),
                      const Text(
                        "CLASSROOM NATIVE SUBTITLE (SANTALI OL CHIKI)",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _liveTranslation,
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF4ADE80)), // Vibrant high-contrast green
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Extracted Lesson Vocabulary Chips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("EXTRACTED LESSON VOCABULARY", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: _extractedVocab.map((v) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${v['sat']} = ${v['hi']} (${v['roman']})",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
