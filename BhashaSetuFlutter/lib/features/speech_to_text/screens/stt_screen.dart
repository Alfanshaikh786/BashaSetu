import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/language.dart';
import '../../../data/models/translation_result.dart';
import '../../../services/asr/asr_service.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class SttTranscriptItem {
  final String id;
  final String time;
  final String speaker;
  final String text;
  final String translation;
  final bool isVerified;

  const SttTranscriptItem({
    required this.id,
    required this.time,
    required this.speaker,
    required this.text,
    required this.translation,
    required this.isVerified,
  });
}

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  String _sourceLang = 'eng';
  String _targetLang = 'sat';
  bool _autoSpeak = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String _interimText = '';

  final List<SttTranscriptItem> _transcripts = [
    const SttTranscriptItem(
      id: 'stt-1',
      time: '00:02 - 00:05',
      speaker: 'Live Speaker',
      text: 'Where is the village health center?',
      translation: 'ᱟᱹᱛᱩ ᱦᱚᱲᱢᱚ ᱥᱟᱶᱟᱨ ᱛᱟᱞᱢᱟ ᱫᱚ ᱚᱠᱟᱨᱮ ᱢᱮᱱᱟᱜᱼᱟ?',
      isVerified: true,
    ),
    const SttTranscriptItem(
      id: 'stt-2',
      time: '00:08 - 00:12',
      speaker: 'Live Speaker',
      text: 'Please drink only clean boiled water.',
      translation: 'ᱫᱟᱭᱟᱠᱟᱛᱮ ᱥᱩᱢᱩᱝ ᱥᱟᱯᱷᱟ ᱦᱮᱰᱮᱡ ᱫᱟᱜ ᱜᱮ ᱧᱩᱭ ᱯᱮ ᱾',
      isVerified: true,
    ),
  ];

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _interimText = '';
    });

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingSeconds++);
    });

    AsrService.instance.startListening(
      langCode: _sourceLang,
      onSpeechStart: () {},
      onResult: (words, isFinal, conf) async {
        if (!mounted) return;
        if (isFinal) {
          final trimmed = words.trim();
          if (trimmed.isNotEmpty) {
            final res = await TranslationDecisionEngine.instance.resolveTranslation(
              text: trimmed,
              sourceLang: _sourceLang,
              targetLang: _targetLang,
            );
            if (!mounted) return;
            final sec = _recordingSeconds;
            final timeStr = "${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}";

            setState(() {
              _interimText = '';
              _transcripts.insert(
                0,
                SttTranscriptItem(
                  id: "stt-${DateTime.now().millisecondsSinceEpoch}",
                  time: timeStr,
                  speaker: 'Live Speaker',
                  text: trimmed,
                  translation: res.targetText,
                  isVerified: res.reliability == TranslationStatus.verified,
                ),
              );
            });

            if (_autoSpeak && res.targetText.isNotEmpty) {
              TtsService.instance.speak(text: res.targetText, langCode: _targetLang);
            }
          }
        } else {
          setState(() => _interimText = words);
        }
      },
    );
  }

  void _stopRecording() {
    AsrService.instance.stopListening();
    _recordingTimer?.cancel();
    _recordingTimer = null;
    setState(() {
      _isRecording = false;
      _interimText = '';
    });
  }

  void _clearAll() {
    setState(() => _transcripts.clear());
  }

  @override
  Widget build(BuildContext context) {
    final targetLangObj = supportedLanguages.firstWhere(
      (l) => l.code == _targetLang,
      orElse: () => supportedLanguages[0],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFDCFCE7)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.auto_awesome_rounded, color: Color(0xFF249144), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  "Real-Time ASR Engine",
                                  style: TextStyle(color: Color(0xFF14532D), fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Speech-to-Text Studio",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Speak or upload audio to generate accurate phonetic transcriptions with synchronized tribal language translations.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Engine Status HUD
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF249144),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "AI4Bharat IndicConformer (int8) • On-Device Neural Model",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Optimal SNR Clarity",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Recording Studio Card
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Language Selection Row
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 14,
                                runSpacing: 10,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("SPOKEN: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
                                      const SizedBox(width: 6),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _sourceLang,
                                          dropdownColor: Colors.white,
                                          items: supportedLanguages.map((l) {
                                            return DropdownMenuItem(value: l.code, child: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _sourceLang = val);
                                          },
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 16),
                                      ),
                                      const Text("TRANSLATE: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
                                      const SizedBox(width: 6),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _targetLang,
                                          dropdownColor: Colors.white,
                                          items: supportedLanguages.map((l) {
                                            return DropdownMenuItem(value: l.code, child: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _targetLang = val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _autoSpeak,
                                        activeColor: const Color(0xFF249144),
                                        onChanged: (v) => setState(() => _autoSpeak = v ?? false),
                                      ),
                                      const Text("Auto-Speak Translation", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Giant Waveform / Acoustic visualizer
                            Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(36, (i) {
                                    final h = _isRecording ? ((i % 5 + 1) * 12.0) : 8.0;
                                    return Container(
                                      width: 4,
                                      height: h,
                                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                      decoration: BoxDecoration(
                                        color: _isRecording ? const Color(0xFF34D399) : const Color(0xFF475569),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Giant Microphone Button
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _toggleRecording,
                                    child: Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isRecording ? const Color(0xFFDC2626) : const Color(0xFF249144),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isRecording ? const Color(0xFFDC2626) : const Color(0xFF249144)).withValues(alpha: 0.4),
                                            blurRadius: 28,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                          size: 46,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isRecording ? "Listening (${_recordingSeconds}s)... Tap to finish" : "Tap to speak in ${_sourceLang.toUpperCase()}",
                                    style: TextStyle(
                                      color: _isRecording ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (_interimText.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFDCFCE7)),
                                ),
                                child: Text(
                                  "Recognizing: $_interimText",
                                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF15803D)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transcript History Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Transcript Segments (${_transcripts.length})",
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                if (_transcripts.isNotEmpty)
                                  Row(
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          final text = _transcripts.map((t) => "[${t.time}] ${t.speaker}: ${t.text}\n    (${targetLangObj.name}): ${t.translation}").join('\n\n');
                                          Clipboard.setData(ClipboardData(text: text));
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied transcripts!")));
                                        },
                                        icon: const Icon(Icons.copy_rounded, size: 14),
                                        label: const Text("Copy", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: _clearAll,
                                        icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                                        label: const Text("Clear", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

                            if (_transcripts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: Text("No transcript captured yet. Tap microphone to speak.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                ),
                              )
                            else
                              ..._transcripts.map((item) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(item.speaker, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF334155))),
                                                const SizedBox(width: 6),
                                                Text("• ${item.time}", style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'monospace')),
                                                if (item.isVerified) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                                                    child: const Text("✓ Verified", style: TextStyle(color: Color(0xFF047857), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(item.text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                            const SizedBox(height: 4),
                                            Text(item.translation, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF059669)),
                                        onPressed: () => TtsService.instance.speak(text: item.translation, langCode: _targetLang),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
