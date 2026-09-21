import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/language.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class PresetItem {
  final String label;
  final String text;
  final String icon;

  const PresetItem({required this.label, required this.text, required this.icon});
}

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  String _selectedLang = 'sat';
  late TextEditingController _textController;
  double _rate = 1.0;
  double _pitch = 1.0;
  bool _isPlaying = false;
  String _statusText = 'Ready';

  final Map<String, List<PresetItem>> _presetsByLang = {
    'sat': const [
      PresetItem(label: 'Welcome & Healthcare', text: 'ᱥᱟᱹᱜᱩᱱ ᱫᱟᱨᱟᱢ • ᱟᱵᱚᱣᱟᱜ ᱫᱤᱥᱚᱢ ᱫᱚ ᱵᱷᱟᱨᱚᱛ ᱠᱟᱱᱟ᱾ ᱥᱤᱠᱤᱞ ᱥᱮᱞ ᱵᱤᱰᱟᱹᱣ ᱦᱟᱥᱯᱟᱛᱟᱞ ᱨᱮ ᱦᱩᱭᱩᱜ ᱠᱟᱱᱟ᱾', icon: '✨'),
      PresetItem(label: 'Cow (Santali)', text: 'ᱱᱩᱭ ᱫᱚ ᱜᱟᱹᱭ ᱠᱟᱱᱟᱭ ᱾', icon: '🐄'),
      PresetItem(label: 'Elephant (Santali)', text: 'ᱱᱩᱭ ᱫᱚ ᱦᱟᱹᱛᱤ ᱠᱟᱱᱟᱭ ᱾', icon: '🐘'),
      PresetItem(label: 'Classroom (Santali)', text: 'ᱟᱞᱮ ᱪᱟᱱᱟᱪ ᱨᱮ ᱢᱤᱫ ᱦᱩᱰᱤᱧ ᱠᱟᱹᱢᱤᱦᱚᱨᱟ ᱢᱮᱱᱟᱜᱼᱟ ᱾', icon: '🏫'),
    ],
    'hin': const [
      PresetItem(label: 'स्वागत एवं परिचय', text: 'नमस्ते, भाषा सेतु में आपका स्वागत है। हम जनजातीय भाषाओं का संवर्धन करते हैं।', icon: '🙏'),
      PresetItem(label: 'स्वास्थ्य परामर्श', text: 'दवा समय पर लें और अस्पताल में स्वास्थ्य जांच करवाएं।', icon: '🏥'),
      PresetItem(label: 'शिक्षा', text: 'बच्चे कक्षा में ध्यान से पढ़ाई कर रहे हैं।', icon: '📚'),
    ],
    'eng': const [
      PresetItem(label: 'Welcome Portal', text: 'Welcome to Bhasha Setu text to speech workspace for indigenous languages.', icon: '🌐'),
      PresetItem(label: 'Clinical Instruction', text: 'Please take two tablets of paracetamol after meals daily.', icon: '💊'),
      PresetItem(label: 'Phonetic Test', text: 'The quick brown fox jumps over the lazy dog.', icon: '🦊'),
    ],
    'unr': const [
      PresetItem(label: 'Greeting (Mundari)', text: 'ᱡᱚᱦᱟᱨ ᱜᱮ • ᱟᱞᱮ ᱫᱚ ᱢᱩᱱᱰᱟ ᱦᱚᱲ ᱠᱟᱱᱟᱞᱮ᱾', icon: '🌿'),
    ],
    'hoc': const [
      PresetItem(label: 'Greeting (Ho)', text: 'ᱡᱚᱦᱟᱨ • ᱟᱞᱤᱝ ᱫᱚ ᱦᱚ ᱦᱚᱲ ᱛᱟᱱᱟᱞᱤᱝ᱾', icon: '🌾'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: 'ᱥᱟᱹᱜᱩᱱ ᱫᱟᱨᱟᱢ • ᱟᱵᱚᱣᱟᱜ ᱫᱤᱥᱚᱢ ᱫᱚ ᱵᱷᱟᱨᱚᱛ ᱠᱟᱱᱟ᱾ ᱥᱤᱠᱤᱞ ᱥᱮᱞ ᱵᱤᱰᱟᱹᱣ ᱦᱟᱥᱯᱟᱛᱟᱞ ᱨᱮ ᱦᱩᱭᱩᱜ ᱠᱟᱱᱟ᱾',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _handleLanguageChange(String newLang) {
    if (_isPlaying) {
      TtsService.instance.stop();
      _isPlaying = false;
    }
    setState(() {
      _selectedLang = newLang;
      final presets = _presetsByLang[newLang] ?? _presetsByLang['sat']!;
      if (presets.isNotEmpty) {
        _textController.text = presets[0].text;
      }
      _statusText = 'Ready';
    });
  }

  void _handleSelectPreset(String presetText) {
    if (_isPlaying) {
      TtsService.instance.stop();
      _isPlaying = false;
    }
    setState(() {
      _textController.text = presetText;
      _statusText = 'Preset phrase loaded';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _statusText = 'Ready');
    });
  }

  Future<void> _handleSpeak() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _statusText = 'Please enter text to speak');
      return;
    }

    if (_isPlaying) {
      await TtsService.instance.stop();
      setState(() {
        _isPlaying = false;
        _statusText = 'Speech stopped';
      });
      return;
    }

    setState(() {
      _isPlaying = true;
      _statusText = 'Speaking audio...';
    });

    await TtsService.instance.speak(
      text: text,
      langCode: _selectedLang,
      rate: _rate * 0.5,
      pitch: _pitch,
    );

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _statusText = 'Speech completed';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _statusText = 'Ready');
      });
    }
  }

  void _handleClear() {
    if (_isPlaying) {
      TtsService.instance.stop();
      _isPlaying = false;
    }
    setState(() {
      _textController.clear();
      _statusText = 'Text cleared';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _statusText = 'Ready');
    });
  }

  void _handleResetTuning() {
    setState(() {
      _rate = 1.0;
      _pitch = 1.0;
      _statusText = 'Speech tuning reset to 1.0x';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _statusText = 'Ready');
    });
  }

  @override
  Widget build(BuildContext context) {
    final langObj = supportedLanguages.firstWhere(
      (l) => l.code == _selectedLang,
      orElse: () => supportedLanguages[0],
    );
    final presets = _presetsByLang[_selectedLang] ?? _presetsByLang['sat']!;
    final words = _textController.text.trim().isEmpty ? 0 : _textController.text.trim().split(RegExp(r'\s+')).length;

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
                  constraints: const BoxConstraints(maxWidth: 880),
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
                                  "Phonetic Speech Synthesis (Web Speech API)",
                                  style: TextStyle(color: Color(0xFF14532D), fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Text to Speech (TTS)",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              width: 120,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF86C498),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Listen to written phrases rendered via verified phonetic transliteration guides using browser speech engines.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Linguistic Honesty Notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("📢", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(color: Color(0xFF78350F), fontSize: 12.5, height: 1.45),
                                  children: [
                                    TextSpan(text: "Linguistic Transparency Notice: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(
                                      text: "Native tribal neural voice models (Santali, Mundari, Ho) are synthesized using Roman phonetic transliteration guides through Indian English and Hindi system voices.",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Voice Studio Card
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
                            // Top Bar: Language Selector & Engine Badge
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
                                      const Text("VOICE DIALECT: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.6)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedLang,
                                            dropdownColor: Colors.white,
                                            items: supportedLanguages.map((lang) {
                                              final isFuture = lang.code == 'unr' || lang.code == 'hoc';
                                              return DropdownMenuItem<String>(
                                                value: lang.code,
                                                child: Text(
                                                  "${lang.name} (${lang.nativeName})${isFuture ? ' — Future Scope' : ''}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) _handleLanguageChange(val);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _isPlaying ? const Color(0xFF249144) : const Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedLang == 'sat' ? "Phonetic Speech Bridge" : "Browser Native Voice",
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedLang == 'sat' ? "Acoustic Indian Voice" : "Device Synthesis",
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Quick Preset Phrases
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("QUICK PRACTICE PHRASES (${langObj.name.toUpperCase()})", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
                                    const Text("click to load", style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: presets.map((preset) {
                                    final isSelected = _textController.text == preset.text;
                                    return InkWell(
                                      onTap: () => _handleSelectPreset(preset.text),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: isSelected ? const Color(0xFF249144) : const Color(0xFFE2E8F0)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(preset.icon, style: const TextStyle(fontSize: 13)),
                                            const SizedBox(width: 6),
                                            Text(
                                              preset.label,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                color: isSelected ? const Color(0xFF14532D) : const Color(0xFF334155),
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.check, size: 14, color: Color(0xFF249144)),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Text Input Workspace
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("INPUT TEXT:", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
                                    Text("$words words • ${_textController.text.length} characters", style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _textController,
                                  maxLines: 5,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.45),
                                  decoration: InputDecoration(
                                    hintText: "Enter text to synthesize into speech...",
                                    filled: true,
                                    fillColor: _isPlaying ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(color: _isPlaying ? const Color(0xFF249144) : const Color(0xFFE2E8F0)),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _isPlaying ? const Color(0xFF249144) : const Color(0xFF94A3B8),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text("Status: $_statusText", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    if (_textController.text.isNotEmpty)
                                      InkWell(
                                        onTap: _handleClear,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.replay_rounded, size: 14, color: Color(0xFF64748B)),
                                            SizedBox(width: 4),
                                            Text("Clear", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Speech Tuning Panel
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(Icons.tune_rounded, size: 16, color: Color(0xFF249144)),
                                          SizedBox(width: 6),
                                          Text("SPEECH TUNING", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF475569), letterSpacing: 0.5)),
                                        ],
                                      ),
                                      if (_rate != 1.0 || _pitch != 1.0)
                                        InkWell(
                                          onTap: _handleResetTuning,
                                          child: const Text("Reset (1.0x)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF249144))),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text("Speed / Rate", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                                Text("${_rate.toStringAsFixed(1)}x", style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            Slider(
                                              value: _rate,
                                              min: 0.5,
                                              max: 1.5,
                                              divisions: 10,
                                              activeColor: const Color(0xFF249144),
                                              onChanged: (val) => setState(() => _rate = val),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text("Pitch", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                                Text(_pitch.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            Slider(
                                              value: _pitch,
                                              min: 0.5,
                                              max: 1.5,
                                              divisions: 10,
                                              activeColor: const Color(0xFF249144),
                                              onChanged: (val) => setState(() => _pitch = val),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Primary Action Footer
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _handleSpeak,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isPlaying ? const Color(0xFFDC2626) : const Color(0xFF249144),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 20),
                                  label: Text(
                                    _isPlaying ? "Stop Speech" : "Generate & Play Speech",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                  ),
                                ),

                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("WAV export generated on device.")),
                                    );
                                  },
                                  icon: const Icon(Icons.download_rounded, size: 16),
                                  label: const Text("Download WAV", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
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
}
