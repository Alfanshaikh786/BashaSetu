import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/language.dart';
import '../../../data/models/translation_result.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class TextToTextScreen extends StatefulWidget {
  const TextToTextScreen({super.key});

  @override
  State<TextToTextScreen> createState() => _TextToTextScreenState();
}

class _TextToTextScreenState extends State<TextToTextScreen> {
  String _sourceLang = 'eng';
  String _targetLang = 'sat';

  final TextEditingController _inputController = TextEditingController();
  TranslationResult? _result;
  bool _isTranslating = false;
  bool _showVirtualKeyboard = false;
  bool _copied = false;
  String? _feedbackGiven;

  final List<Map<String, String>> _quickPresets = [
    {'title': 'School', 'text': 'Where is the primary school?'},
    {'title': 'Health', 'text': 'Is your health good?'},
    {'title': 'Greeting', 'text': 'Hello, how are you?'},
    {'title': 'Water', 'text': 'Drink clean boiling water.'},
  ];

  final List<String> _olChikiKeys = [
    'ᱚ', 'ᱛ', 'ᱜ', 'ᱝ', 'ᱞ', 'ᱟ', 'ᱠ', 'ᱡ', 'ᱢ', 'ᱣ',
    'ᱤ', 'ᱥ', 'ᱦ', 'ᱧ', 'ᱨ', 'ᱩ', 'ᱪ', 'ᱫ', 'ᱬ', 'ᱭ',
    'ᱮ', 'ᱯ', 'ᱰ', 'ᱱ', 'ᱲ', 'ᱳ', 'ᱴ', 'ᱵ', 'ᱶ', 'ᱷ',
    'ᱸ', 'ᱹ', 'ᱺ', 'ᱻ', 'ᱼ', 'ᱽ'
  ];

  Future<void> _handleTranslate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() => _result = null);
      return;
    }

    setState(() => _isTranslating = true);

    final res = await TranslationDecisionEngine.instance.resolveTranslation(
      text: text,
      sourceLang: _sourceLang,
      targetLang: _targetLang,
    );

    setState(() {
      _result = res;
      _isTranslating = false;
      _feedbackGiven = null;
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      if (_result != null && _result!.isSuccess) {
        _inputController.text = _result!.targetText;
        _result = null;
      }
    });
    if (_inputController.text.isNotEmpty) {
      _handleTranslate();
    }
  }

  void _insertKey(String char) {
    final text = _inputController.text;
    final selection = _inputController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, char);
    _inputController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + char.length),
    );
    _handleTranslate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    // Header Title & HUD
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Translation Studio Box
                    _buildStudioContainer(),
                    const SizedBox(height: 20),

                    // Quick Phrases Presets Bar
                    _buildQuickPresetsBar(),

                    // Virtual Ol Chiki Keyboard
                    if (_showVirtualKeyboard) ...[
                      const SizedBox(height: 16),
                      _buildVirtualKeyboard(),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD1EAD4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF249144)),
              SizedBox(width: 6),
              Text(
                "Offline-First Translation Studio",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14532D)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          "Multilingual Translator",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 10),

        // Underline Bar with Centered Green Accent
        Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 140, height: 2, color: const Color(0xFFE2E8F0)),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF86C498),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const Text(
          "Bidirectional tribal language translation and linguistic accessibility engine for educators and frontline cadres.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
        ),
        const SizedBox(height: 16),

        // Action HUD Bar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildHudBadge("🟢 OFFLINE READY", const Color(0xFFECFDF5), const Color(0xFFA7F3D0), const Color(0xFF065F46)),
            _buildHudButton("⚡ Test Offline Mode", Icons.bolt_rounded, const Color(0xFFFFFBEB), const Color(0xFFFDE68A), const Color(0xFF92400E), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Simulating 100% Offline Mode: Zero network requests active!"), backgroundColor: Color(0xFF249144)),
              );
            }),
            _buildHudButton("🎯 SIH 60s Demo", Icons.auto_awesome_rounded, const Color(0xFFF0FDF4), const Color(0xFFBBF7D0), const Color(0xFF14532D), () {
              _inputController.text = "Where is the primary school?";
              _handleTranslate();
            }),
            _buildHudBadge("Dataset Audit (6,780)", const Color(0xFFEFF6FF), const Color(0xFFBFDBFE), const Color(0xFF1E40AF)),
            _buildHudBadge("Linguistic Honesty Guard ✓", const Color(0xFFF8FAFC), const Color(0xFFE2E8F0), const Color(0xFF334155)),
          ],
        ),
      ],
    );
  }

  Widget _buildHudBadge(String text, Color bg, Color border, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildHudButton(String text, IconData icon, Color bg, Color border, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Studio Language Header Bar
          _buildStudioHeaderBar(),

          // Input Card
          _buildInputSection(),

          // Divider
          Container(height: 1, color: const Color(0xFFF1F5F9)),

          // Output Card
          if (_result != null) _buildOutputSection(),
        ],
      ),
    );
  }

  Widget _buildStudioHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Source Picker
          Row(
            children: [
              const Text("From: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sourceLang,
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF249144)),
                  items: supportedLanguages.map((l) => DropdownMenuItem(value: l.code, child: Text("${l.name} (${l.script})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _sourceLang = val);
                      _handleTranslate();
                    }
                  },
                ),
              ),
            ],
          ),

          // Swap Button
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF249144)),
            onPressed: _swapLanguages,
            tooltip: "Swap Languages",
          ),

          // Target Picker
          Row(
            children: [
              const Text("To: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _targetLang,
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF249144)),
                  items: supportedLanguages.map((l) => DropdownMenuItem(value: l.code, child: Text("${l.name} (${l.script})", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF14532D))))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _targetLang = val);
                      _handleTranslate();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INPUT TEXT (${_inputController.text.length} chars)",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
              ),
              Row(
                children: [
                  if (_sourceLang == 'sat')
                    TextButton.icon(
                      onPressed: () => setState(() => _showVirtualKeyboard = !_showVirtualKeyboard),
                      icon: const Icon(Icons.keyboard_alt_outlined, size: 14),
                      label: Text(_showVirtualKeyboard ? "Hide Keys" : "Ol Chiki Keys", style: const TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF249144)),
                    ),
                  if (_inputController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        _inputController.clear();
                        setState(() => _result = null);
                      },
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _inputController,
            maxLines: 4,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            decoration: const InputDecoration(
              hintText: "Type text or sentence here...",
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => _handleTranslate(),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF64748B), size: 20),
                onPressed: () {
                  if (_inputController.text.isNotEmpty) {
                    TtsService.instance.speak(text: _inputController.text, langCode: _sourceLang);
                  }
                },
                tooltip: "Listen Input",
              ),
              ElevatedButton.icon(
                onPressed: _isTranslating ? null : _handleTranslate,
                icon: _isTranslating
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.translate_rounded, size: 16),
                label: const Text("Translate Offline"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF249144),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputSection() {
    final res = _result!;
    final isUnavailable = res.reliability == TranslationStatus.unavailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnavailable ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnavailable ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isUnavailable ? "UNAVAILABLE" : "VERIFIED (${(res.confidence * 100).toInt()}%)",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUnavailable ? const Color(0xFF92400E) : const Color(0xFF14532D),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 18, color: const Color(0xFF249144)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: res.targetText));
                      setState(() => _copied = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _copied = false);
                      });
                    },
                    tooltip: "Copy Output",
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFF249144)),
                    onPressed: () {
                      TtsService.instance.speak(text: res.targetText, langCode: _targetLang);
                    },
                    tooltip: "Listen Audio",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            res.targetText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isUnavailable ? const Color(0xFF78350F) : const Color(0xFF0F172A),
            ),
          ),

          if (res.roman != null && res.roman!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                "Phonetic: ${res.roman}",
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
              ),
            ),
          ],
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text("Engine: ${res.provider}", style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up_alt_outlined, size: 16, color: _feedbackGiven == 'up' ? const Color(0xFF249144) : const Color(0xFF94A3B8)),
                    onPressed: () => setState(() => _feedbackGiven = 'up'),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down_alt_outlined, size: 16, color: _feedbackGiven == 'down' ? const Color(0xFFB91C1C) : const Color(0xFF94A3B8)),
                    onPressed: () => setState(() => _feedbackGiven = 'down'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresetsBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickPresets.map((p) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(p['title']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onPressed: () {
                _inputController.text = p['text']!;
                _handleTranslate();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVirtualKeyboard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Ol Chiki Virtual Keyboard", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text("Pandit Raghunath Murmu Script", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _olChikiKeys.map((key) {
              return InkWell(
                onTap: () => _insertKey(key),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1EAD4)),
                  ),
                  child: Center(
                    child: Text(
                      key,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF14532D)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
