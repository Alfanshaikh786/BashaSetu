import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/language.dart';
import '../../../data/models/translation_result.dart';
import '../../../services/asr/asr_service.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class LessonSegment {
  final String id;
  final String timestamp;
  final String speaker;
  final String text;
  final String translation;
  final bool isVerified;
  final bool needsReview;

  const LessonSegment({
    required this.id,
    required this.timestamp,
    required this.speaker,
    required this.text,
    required this.translation,
    required this.isVerified,
    required this.needsReview,
  });
}

class TeacherModeScreen extends StatefulWidget {
  const TeacherModeScreen({super.key});

  @override
  State<TeacherModeScreen> createState() => _TeacherModeScreenState();
}

class _TeacherModeScreenState extends State<TeacherModeScreen> {
  String _sourceLang = 'hin';
  String _targetLang = 'sat';
  bool _isRecording = false;
  int _lessonSeconds = 0;
  Timer? _clockTimer;

  String _liveCaption = "आज हम गणित और पहाड़ों के बारे में पढ़ेंगे।";
  String _liveTranslation = "ᱛᱮᱦᱮᱧ ᱫᱚ ᱮᱞᱠᱷᱟ ᱟᱨ ᱵᱩᱨᱩ ᱠᱚ ᱵᱟᱵᱚᱛ ᱵᱚᱱ ᱯᱟᱲᱦᱟᱣ-ᱟ ᱾";
  String? _guardrailNotice;
  String _activeTab = 'captions'; // 'captions' | 'summary' | 'vocab'

  final List<LessonSegment> _segments = [
    const LessonSegment(
      id: 'seg-1',
      timestamp: '00:15',
      speaker: 'Teacher',
      text: 'आज हम गणित और पहाड़ों के बारे में पढ़ेंगे।',
      translation: 'ᱛᱮᱦᱮᱧ ᱫᱚ ᱮᱞᱠᱷᱟ ᱟᱨ ᱵᱩᱨᱩ ᱠᱚ ᱵᱟᱵᱚᱛ ᱵᱚᱱ ᱯᱟᱲᱦᱟᱣ-ᱟ ᱾',
      isVerified: true,
      needsReview: false,
    ),
    const LessonSegment(
      id: 'seg-2',
      timestamp: '00:32',
      speaker: 'Teacher',
      text: 'सभी बच्चे अपनी किताबें खोलें।',
      translation: 'ᱥᱟᱱᱟᱢ ᱜᱤᱫᱽᱨᱟᱹ ᱟᱯᱱᱟᱨᱟᱜ ᱯᱚᱛᱚᱵ ᱠᱚ ᱡᱷᱤᱡ ᱯᱮ ᱾',
      isVerified: true,
      needsReview: false,
    ),
  ];

  final List<Map<String, String>> _extractedVocab = [
    {'sat': 'ᱮᱞᱠᱷᱟ', 'roman': 'Elkha', 'hi': 'गणित', 'en': 'Mathematics'},
    {'sat': 'ᱵᱩᱨᱩ', 'roman': 'Buru', 'hi': 'पहाड़', 'en': 'Mountain'},
    {'sat': 'ᱯᱟᱲᱦᱟᱣ', 'roman': 'Parhao', 'hi': 'पढ़ना', 'en': 'Study / Read'},
    {'sat': 'ᱯᱚᱛᱚᱵ', 'roman': 'Potob', 'hi': 'किताब', 'en': 'Book'},
    {'sat': 'ᱜᱤᱫᱽᱨᱟᱹ', 'roman': 'Gidra', 'hi': 'बच्चे', 'en': 'Children'},
  ];

  @override
  void dispose() {
    _clockTimer?.cancel();
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
    setState(() => _guardrailNotice = null);

    if (_sourceLang == 'unr') {
      setState(() => _guardrailNotice = 'Mundari ASR is currently under development. This language will be enabled after validated training and testing.');
      return;
    }
    if (_sourceLang == 'hoc') {
      setState(() => _guardrailNotice = 'Ho ASR is currently under development. This language will be enabled after validated training and testing.');
      return;
    }

    setState(() {
      _isRecording = true;
      _clockTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _lessonSeconds++);
      });
    });

    AsrService.instance.startListening(
      langCode: _sourceLang,
      onSpeechStart: () {},
      onResult: (words, isFinal, conf) async {
        if (!mounted) return;
        setState(() => _liveCaption = words);
        if (isFinal && words.trim().isNotEmpty) {
          final res = await TranslationDecisionEngine.instance.resolveTranslation(
            text: words,
            sourceLang: _sourceLang,
            targetLang: _targetLang,
          );
          if (!mounted) return;
          final sec = _lessonSeconds;
          final timeStr = "${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}";
          setState(() {
            _liveTranslation = res.targetText;
            _segments.insert(
              0,
              LessonSegment(
                id: "seg-${DateTime.now().millisecondsSinceEpoch}",
                timestamp: timeStr,
                speaker: 'Teacher',
                text: words,
                translation: res.targetText,
                isVerified: res.reliability == TranslationStatus.verified,
                needsReview: res.reliability == TranslationStatus.unavailable,
              ),
            );
          });
        }
      },
    );
  }

  void _stopRecording() {
    AsrService.instance.stopListening();
    _clockTimer?.cancel();
    _clockTimer = null;
    setState(() => _isRecording = false);
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final targetLangObj = supportedLanguages.firstWhere(
      (l) => l.code == _targetLang,
      orElse: () => supportedLanguages[0],
    );
    final verifiedCount = _segments.where((s) => s.isVerified).length;
    final reviewCount = _segments.where((s) => s.needsReview).length;

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
                      // Top Classroom Bar
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: Color(0xFF4338CA), size: 24),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "TEACHER MODE",
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Live classroom captions, lesson recording & automatic vocabulary extractor.",
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("Teacher: ", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _sourceLang,
                                          dropdownColor: Colors.white,
                                          items: supportedLanguages.map((l) {
                                            return DropdownMenuItem<String>(
                                              value: l.code,
                                              child: Text(
                                                "${l.name}${l.isTribal ? (l.code == 'sat' ? ' ★' : ' (Phase 2/3)') : ''}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _sourceLang = val;
                                                _guardrailNotice = null;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                        child: Text("→", style: TextStyle(color: Color(0xFFCBD5E1))),
                                      ),
                                      const Text("Captions: ", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _targetLang,
                                          dropdownColor: Colors.white,
                                          items: supportedLanguages.map((l) {
                                            return DropdownMenuItem<String>(
                                              value: l.code,
                                              child: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _targetLang = val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Timer Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE0E7FF)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 15, color: Color(0xFF312E81)),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatTimer(_lessonSeconds),
                                        style: const TextStyle(
                                          color: Color(0xFF312E81),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Responsible AI Guardrail Banner
                      if (_guardrailNotice != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Responsible AI Guardrail", style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(_guardrailNotice!, style: const TextStyle(color: Color(0xFFB45309), fontSize: 11.5)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Color(0xFFD97706)),
                                onPressed: () => setState(() => _guardrailNotice = null),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Giant Live Classroom Captions Screen (Optimized for Projector / Smartboard)
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A), // slate-900
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF1E293B)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isRecording ? "LIVE CLASSROOM CAPTIONS (ACTIVE)" : "STANDBY (PRESS START LESSON)",
                                      style: const TextStyle(
                                        color: Color(0xFF34D399),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: _toggleRecording,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isRecording ? const Color(0xFFDC2626) : const Color(0xFF249144),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 16),
                                  label: Text(_isRecording ? "Pause Captions" : "Start Lesson Captions", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 28, thickness: 1, color: Color(0xFF1E293B)),

                            // Spoken Text (Teacher)
                            ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 64),
                              child: Text(
                                _liveCaption.isNotEmpty ? _liveCaption : "Teacher's spoken words will appear here in real-time...",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: _liveCaption.isNotEmpty ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Parallel Multilingual Translation Caption
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CLASSROOM TRANSLATION (${targetLangObj.name.toUpperCase()}):",
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _liveTranslation.isNotEmpty ? _liveTranslation : "Parallel tribal language subtitle display...",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6EE7B7), // vibrant mint green
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3-Tab Section: Lesson History, Summary & Extracted Vocabulary
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            // Tab Header
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _activeTab = 'captions'),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _activeTab == 'captions' ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: _activeTab == 'captions'
                                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Lesson Segments (${_segments.length})",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: _activeTab == 'captions' ? const Color(0xFF312E81) : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _activeTab = 'summary'),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _activeTab == 'summary' ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: _activeTab == 'summary'
                                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Lesson Summary",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: _activeTab == 'summary' ? const Color(0xFF312E81) : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _activeTab = 'vocab'),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _activeTab == 'vocab' ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: _activeTab == 'vocab'
                                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Vocabulary Extracted (${_extractedVocab.length})",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: _activeTab == 'vocab' ? const Color(0xFF312E81) : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tab Body
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Builder(
                                builder: (context) {
                                  if (_activeTab == 'captions') {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Recorded utterances from this classroom session:", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                            Row(
                                              children: [
                                                OutlinedButton.icon(
                                                  onPressed: () {},
                                                  icon: const Icon(Icons.download_rounded, size: 14),
                                                  label: const Text("TXT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                OutlinedButton.icon(
                                                  onPressed: () {},
                                                  icon: const Icon(Icons.subtitles_rounded, size: 14),
                                                  label: const Text("SRT Subtitles", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        ..._segments.map((seg) {
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.all(14),
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
                                                          Text(seg.speaker, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF334155))),
                                                          const SizedBox(width: 6),
                                                          Text("• ${seg.timestamp}", style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'monospace')),
                                                          if (seg.isVerified) ...[
                                                            const SizedBox(width: 8),
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                                                              child: const Text("✓ Verified", style: TextStyle(color: Color(0xFF047857), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(seg.text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                                      const SizedBox(height: 2),
                                                      Text(seg.translation, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF059669)),
                                                  onPressed: () => TtsService.instance.speak(text: seg.translation, langCode: _targetLang),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    );
                                  } else if (_activeTab == 'summary') {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 1.8,
                                          children: [
                                            _buildSummaryCard("TOTAL DURATION", "${_lessonSeconds ~/ 60}m ${_lessonSeconds % 60}s", const Color(0xFFF8FAFC), const Color(0xFF64748B), const Color(0xFF0F172A)),
                                            _buildSummaryCard("TOTAL UTTERANCES", "${_segments.length}", const Color(0xFFEEF2FF), const Color(0xFF4338CA), const Color(0xFF312E81)),
                                            _buildSummaryCard("VERIFIED PHRASES", "$verifiedCount", const Color(0xFFECFDF5), const Color(0xFF047857), const Color(0xFF064E3B)),
                                            _buildSummaryCard("LOW-CONFIDENCE", "$reviewCount", const Color(0xFFFFFBEB), const Color(0xFFB45309), const Color(0xFF78350F)),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text("Classroom Pedagogical Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                              SizedBox(height: 4),
                                              Text(
                                                "This lesson record facilitates bilingual bridge learning. Tribal students can view their mother tongue (Santali in Ol Chiki) aligned with instructional Hindi/English, accelerating classroom comprehension without language disorientation.",
                                                style: TextStyle(color: Color(0xFF475569), fontSize: 12, height: 1.45),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Vocab tab
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Automatically extracted key vocabulary encountered during this lesson:",
                                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                        ),
                                        const SizedBox(height: 14),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 2.5,
                                          ),
                                          itemCount: _extractedVocab.length,
                                          itemBuilder: (context, i) {
                                            final v = _extractedVocab[i];
                                            return Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius: BorderRadius.circular(18),
                                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(v['sat']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                                      Text("(${v['roman']})", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                                                      Text("HI: ${v['hi']} • EN: ${v['en']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF047857))),
                                                    ],
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF059669), size: 20),
                                                    onPressed: () => TtsService.instance.speak(text: v['sat']!, langCode: 'sat'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ),
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

  Widget _buildSummaryCard(String title, String value, Color bg, Color labelColor, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: labelColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: labelColor, letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: valueColor)),
        ],
      ),
    );
  }
}
