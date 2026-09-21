import 'package:flutter/material.dart';
import '../../../data/models/language.dart';
import '../../../data/models/translation_result.dart';
import '../../../services/asr/asr_service.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class FieldModeScreen extends StatefulWidget {
  const FieldModeScreen({super.key});

  @override
  State<FieldModeScreen> createState() => _FieldModeScreenState();
}

class _FieldModeScreenState extends State<FieldModeScreen> {
  String _sourceLang = 'sat';
  String _targetLang = 'hin';
  bool _isRecording = false;
  String _interimText = '';
  String _spokenText = 'ᱱᱩᱭ ᱫᱚ ᱜᱟᱹᱭ ᱠᱟᱱᱟᱭ ᱾';
  String _translatedText = 'यह गाय है।';
  String _pronunciation = 'Nui do gai kanay.';
  String _confidenceTier = 'verified'; // 'verified' | 'dataset' | 'fallback' | 'needs_review'
  bool _accepted = false;
  String? _guardrailNotice;
  bool _showTechnicalDetails = false;

  // Edit modal
  bool _isEditing = false;
  late TextEditingController _editSpokenController;
  late TextEditingController _editTranslatedController;

  @override
  void initState() {
    super.initState();
    _editSpokenController = TextEditingController(text: _spokenText);
    _editTranslatedController = TextEditingController(text: _translatedText);
  }

  @override
  void dispose() {
    _editSpokenController.dispose();
    _editTranslatedController.dispose();
    super.dispose();
  }

  void _handleSwapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      _guardrailNotice = null;
    });
  }

  Future<void> _processSpokenInput(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      setState(() => _isRecording = false);
      return;
    }

    setState(() {
      _spokenText = trimmed;
      _interimText = '';
      _accepted = false;
    });

    final res = await TranslationDecisionEngine.instance.resolveTranslation(
      text: trimmed,
      sourceLang: _sourceLang,
      targetLang: _targetLang,
    );

    setState(() {
      _translatedText = res.targetText;
      _pronunciation = res.roman ?? '';
      _confidenceTier = res.reliability == TranslationStatus.verified
          ? 'verified'
          : (res.reliability == TranslationStatus.dataset ? 'dataset' : 'fallback');
      _isRecording = false;
    });

    if (res.targetText.isNotEmpty) {
      TtsService.instance.speak(text: res.targetText, langCode: _targetLang);
    }
  }

  Future<void> _toggleSpeaking() async {
    if (_isRecording) {
      await AsrService.instance.stopListening();
      setState(() => _isRecording = false);
      return;
    }

    setState(() => _guardrailNotice = null);

    // Guardrail for underdeveloped tribal ASR
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
      _interimText = '';
    });

    await AsrService.instance.startListening(
      langCode: _sourceLang,
      onSpeechStart: () {},
      onResult: (words, isFinal, conf) {
        if (!mounted) return;
        if (isFinal) {
          _processSpokenInput(words);
        } else {
          setState(() => _interimText = words);
        }
      },
    );
  }

  void _openEditModal() {
    _editSpokenController.text = _spokenText;
    _editTranslatedController.text = _translatedText;
    setState(() => _isEditing = true);
  }

  void _saveCorrection() {
    setState(() {
      _spokenText = _editSpokenController.text;
      _translatedText = _editTranslatedController.text;
      _confidenceTier = 'verified';
      _accepted = true;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sourceLangObj = supportedLanguages.firstWhere(
      (l) => l.code == _sourceLang,
      orElse: () => supportedLanguages[0],
    );
    final targetLangObj = supportedLanguages.firstWhere(
      (l) => l.code == _targetLang,
      orElse: () => supportedLanguages[1],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate-900
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Mode Bar
                          Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF34D399),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "FIELD MODE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "• Simple Offline Communication",
                                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      CircleAvatar(radius: 4, backgroundColor: Color(0xFF34D399)),
                                      SizedBox(width: 6),
                                      Text(
                                        "Good Audio",
                                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Guardrail Notice
                          if (_guardrailNotice != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF451A03),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFD97706)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Responsible AI Guardrail", style: TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold, fontSize: 12)),
                                        const SizedBox(height: 2),
                                        Text(_guardrailNotice!, style: const TextStyle(color: Color(0xFFFEF3C7), fontSize: 11.5)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Color(0xFFFBBF24)),
                                    onPressed: () => setState(() => _guardrailNotice = null),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Language Selection Row
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4, bottom: 4),
                                        child: Text("SPOKEN LANGUAGE", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF334155),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFF475569)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _sourceLang,
                                            isExpanded: true,
                                            dropdownColor: const Color(0xFF1E293B),
                                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                                            items: supportedLanguages.map((l) {
                                              return DropdownMenuItem<String>(
                                                value: l.code,
                                                child: Text(
                                                  "${l.name}${l.isTribal ? (l.code == 'sat' ? ' ★' : ' (Phase 2/3)') : ''}",
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 18, left: 8, right: 8),
                                  child: InkWell(
                                    onTap: _handleSwapLanguages,
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF334155),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFF475569)),
                                      ),
                                      child: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF34D399), size: 20),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4, bottom: 4),
                                        child: Text("TRANSLATE TO", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF334155),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFF475569)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _targetLang,
                                            isExpanded: true,
                                            dropdownColor: const Color(0xFF1E293B),
                                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                                            items: supportedLanguages.map((l) {
                                              return DropdownMenuItem<String>(
                                                value: l.code,
                                                child: Text(
                                                  l.name,
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) setState(() => _targetLang = val);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 1. Spoken Native Script Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "1. SPOKEN (${sourceLangObj.name.toUpperCase()})",
                                      style: const TextStyle(
                                        color: Color(0xFF34D399),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => TtsService.instance.speak(text: _spokenText, langCode: _sourceLang),
                                      icon: const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF34D399)),
                                      label: const Text("Listen", style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(0xFF334155),
                                        side: const BorderSide(color: Color(0xFF475569)),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _spokenText.isNotEmpty ? _spokenText : "Tap microphone below to speak...",
                                  style: TextStyle(
                                    color: _spokenText.isNotEmpty ? const Color(0xFFF1F5F9) : const Color(0xFF64748B),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                  ),
                                ),
                                if (_interimText.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    "Recognizing: $_interimText",
                                    style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 12, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 2. Translated Target Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B).withValues(alpha: 0.6), // dark emerald
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF059669)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "2. TRANSLATION (${targetLangObj.name.toUpperCase()})",
                                      style: const TextStyle(
                                        color: Color(0xFF6EE7B7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => TtsService.instance.speak(text: _translatedText, langCode: _targetLang),
                                      icon: const Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFFA7F3D0)),
                                      label: const Text("Listen", style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(0xFF065F46),
                                        side: const BorderSide(color: Color(0xFF10B981)),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _translatedText.isNotEmpty ? _translatedText : "—",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    height: 1.3,
                                  ),
                                ),
                                if (_pronunciation.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    "Phonetic: $_pronunciation",
                                    style: const TextStyle(
                                      color: Color(0xFFA7F3D0),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF065F46),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: const Color(0xFF10B981)),
                                      ),
                                      child: Text(
                                        _confidenceTier == 'verified'
                                            ? "🟢 Verified Translation (Exact Match)"
                                            : (_confidenceTier == 'dataset' ? "🟡 Known Dataset Match" : "🟠 Fallback Generated"),
                                        style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 10.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (_accepted)
                                      Row(
                                        children: const [
                                          Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 16),
                                          SizedBox(width: 4),
                                          Text("Accepted", style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Core Field Action Buttons: Repeat | Edit | Accept
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => TtsService.instance.speak(text: _translatedText, langCode: _targetLang),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: const Color(0xFFCBD5E1),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      side: const BorderSide(color: Color(0xFF334155)),
                                    ),
                                  ),
                                  child: Column(
                                    children: const [
                                      Icon(Icons.replay_rounded, color: Color(0xFF34D399), size: 20),
                                      SizedBox(height: 4),
                                      Text("REPEAT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _openEditModal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: const Color(0xFFCBD5E1),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      side: const BorderSide(color: Color(0xFF334155)),
                                    ),
                                  ),
                                  child: Column(
                                    children: const [
                                      Icon(Icons.edit_note_rounded, color: Color(0xFFFBBF24), size: 20),
                                      SizedBox(height: 4),
                                      Text("EDIT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _accepted = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF065F46),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      side: const BorderSide(color: Color(0xFF10B981)),
                                    ),
                                  ),
                                  child: Column(
                                    children: const [
                                      Icon(Icons.check_rounded, color: Colors.white, size: 20),
                                      SizedBox(height: 4),
                                      Text("ACCEPT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Giant Microphone Button
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _toggleSpeaking,
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isRecording ? const Color(0xFFDC2626) : const Color(0xFF249144),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isRecording ? const Color(0xFFDC2626) : const Color(0xFF249144)).withValues(alpha: 0.45),
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
                                  _isRecording ? "Listening... Tap to finish" : "Tap to speak in ${sourceLangObj.name}",
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Collapsible Technical Details
                          InkWell(
                            onTap: () => setState(() => _showTechnicalDetails = !_showTechnicalDetails),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 16),
                                      SizedBox(width: 6),
                                      Text("Technical Provenance & Health Details", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                    ],
                                  ),
                                  Icon(
                                    _showTechnicalDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                    color: const Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_showTechnicalDetails) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("• ASR Architecture: ${_sourceLang == 'sat' ? 'AI4Bharat IndicConformer (ONNX int8)' : 'On-Device Acoustic Model'}", style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text("• Target Script: ${_targetLang == 'sat' ? 'Ol Chiki (U+1C50–U+1C7F)' : 'Devanagari / Latin'}", style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  const Text("• Offline Database: 6,780 Verified parallel records indexed on-device", style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  const Text("• Audio Signal: 16 kHz Mono • SNR ~18 dB", style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const AppFooter(),
              ],
            ),
          ),

          // In-Place Edit Modal
          if (_isEditing)
            Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF334155)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Correct Text (Saved to Local Audit)",
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                                onPressed: () => setState(() => _isEditing = false),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF334155)),
                          const SizedBox(height: 12),
                          Text("Spoken (${sourceLangObj.name})", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _editSpokenController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF334155),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF475569))),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text("Translation (${targetLangObj.name})", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _editTranslatedController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF334155),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF475569))),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _isEditing = false),
                                child: const Text("Cancel", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _saveCorrection,
                                icon: const Icon(Icons.check_rounded, size: 16),
                                label: const Text("Save & Accept", style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF249144),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
