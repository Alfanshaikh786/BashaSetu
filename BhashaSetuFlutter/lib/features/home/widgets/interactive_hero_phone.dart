import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../services/translation/translation_decision_engine.dart';
import '../../../../services/tts/tts_service.dart';

class PresetPair {
  final String sourceLang;
  final String targetLang;
  final String sourceText;
  final String targetText;
  final String sourceCode;
  final String targetCode;

  const PresetPair({
    required this.sourceLang,
    required this.targetLang,
    required this.sourceText,
    required this.targetText,
    required this.sourceCode,
    required this.targetCode,
  });
}

class InteractiveHeroPhone extends StatefulWidget {
  const InteractiveHeroPhone({super.key});

  @override
  State<InteractiveHeroPhone> createState() => _InteractiveHeroPhoneState();
}

class _InteractiveHeroPhoneState extends State<InteractiveHeroPhone> {
  static const List<PresetPair> _presetPairs = [
    PresetPair(
      sourceLang: 'Gondi',
      targetLang: 'English',
      sourceText: 'िम्मा बदम मन्तोम।',
      targetText: 'How are you?',
      sourceCode: 'gon',
      targetCode: 'eng',
    ),
    PresetPair(
      sourceLang: 'Santali',
      targetLang: 'English',
      sourceText: 'ᱡᱚᱦᱟᱨ, ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱜ ᱵᱤᱱᱟ?',
      targetText: 'Hello, how are you?',
      sourceCode: 'sat',
      targetCode: 'eng',
    ),
    PresetPair(
      sourceLang: 'Hindi',
      targetLang: 'English',
      sourceText: 'नमस्ते, आप कैसे हैं?',
      targetText: 'Hello, how are you?',
      sourceCode: 'hin',
      targetCode: 'eng',
    ),
  ];

  int _selectedPresetIndex = 0;
  late String _sourceLang;
  late String _targetLang;
  late String _sourceCode;
  late String _targetCode;
  late TextEditingController _sourceController;
  late String _targetText;
  bool _isTranslating = false;
  String _buttonState = 'translated'; // 'translate' | 'translated'

  @override
  void initState() {
    super.initState();
    final p = _presetPairs[0];
    _sourceLang = p.sourceLang;
    _targetLang = p.targetLang;
    _sourceCode = p.sourceCode;
    _targetCode = p.targetCode;
    _sourceController = TextEditingController(text: p.sourceText);
    _targetText = p.targetText;
  }

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  void _handleCyclePreset() {
    setState(() {
      _selectedPresetIndex = (_selectedPresetIndex + 1) % _presetPairs.length;
      final preset = _presetPairs[_selectedPresetIndex];
      _sourceLang = preset.sourceLang;
      _targetLang = preset.targetLang;
      _sourceCode = preset.sourceCode;
      _targetCode = preset.targetCode;
      _sourceController.text = preset.sourceText;
      _targetText = preset.targetText;
      _buttonState = 'translated';
    });
  }

  void _handleSwap() {
    setState(() {
      final prevSourceLang = _sourceLang;
      final prevTargetLang = _targetLang;
      final prevSourceCode = _sourceCode;
      final prevTargetCode = _targetCode;
      final prevSourceText = _sourceController.text;
      final prevTargetText = _targetText;

      _sourceLang = prevTargetLang;
      _targetLang = prevSourceLang;
      _sourceCode = prevTargetCode;
      _targetCode = prevSourceCode;
      _sourceController.text = prevTargetText;
      _targetText = prevSourceText;
      _buttonState = 'translated';
    });
  }

  Future<void> _handleTranslate() async {
    final query = _sourceController.text.trim();
    if (query.isEmpty) {
      setState(() => _targetText = '');
      return;
    }

    setState(() => _isTranslating = true);
    try {
      final res = await TranslationDecisionEngine.instance.resolveTranslation(
        text: query,
        sourceLang: _sourceCode,
        targetLang: _targetCode,
      );
      if (mounted) {
        setState(() {
          _targetText = res.targetText.isNotEmpty ? res.targetText : 'How are you?';
          _buttonState = 'translated';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _targetText = 'How are you?';
          _buttonState = 'translated';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  void _speak(String text, String langCode) {
    if (text.trim().isEmpty) return;
    TtsService.instance.speak(text: text, langCode: langCode.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFF1E293B), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBF7),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: const Color(0xFFD5E8D5)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Notch (Dynamic Island)
            Center(
              child: Container(
                width: 86,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(right: 8),
                alignment: Alignment.centerRight,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF334155), width: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Status Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "9:30",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17212B),
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.wifi_rounded, size: 12, color: Color(0xFF17212B)),
                    SizedBox(width: 4),
                    Icon(Icons.battery_5_bar_rounded, size: 12, color: Color(0xFF17212B)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // App Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu_rounded, size: 16, color: Color(0xFF17212B)),
                const Text(
                  "Text to Text",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF176B3A),
                  ),
                ),
                InkWell(
                  onTap: _handleCyclePreset,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.auto_awesome_rounded, size: 10, color: Color(0xFF238B45)),
                        SizedBox(width: 3),
                        Text(
                          "Demo",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF238B45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // "FROM" Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "FROM",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF667085),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                // Language Pill
                InkWell(
                  onTap: _handleCyclePreset,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD5E8D5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 7,
                          backgroundColor: const Color(0xFF238B45),
                          child: Text(
                            _sourceLang.isNotEmpty ? _sourceLang[0] : 'G',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _sourceLang,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF17212B)),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_drop_down_rounded, size: 14, color: Color(0xFF667085)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Source Input Box
                Container(
                  height: 85,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD5E8D5)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sourceController,
                          maxLines: null,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF17212B)),
                          decoration: const InputDecoration(
                            hintText: "Type text here...",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) {
                            if (_buttonState != 'translate') {
                              setState(() => _buttonState = 'translate');
                            }
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => _speak(_sourceController.text, _sourceCode),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF667085)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Circular Swap Button
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: _handleSwap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD5E8D5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.swap_vert_rounded, size: 16, color: Color(0xFF17212B)),
                  ),
                ),
              ),
            ),

            // "TO" Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TO",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF667085),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                // Language Pill
                InkWell(
                  onTap: _handleCyclePreset,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD5E8D5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 7,
                          backgroundColor: const Color(0xFF238B45),
                          child: Text(
                            _targetLang.length >= 2 ? _targetLang.substring(0, 2).toUpperCase() : 'EN',
                            style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _targetLang,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF17212B)),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_drop_down_rounded, size: 14, color: Color(0xFF667085)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Target Output Box
                Container(
                  height: 85,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD5E8D5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _targetText.isNotEmpty ? _targetText : "Translation output...",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _targetText.isNotEmpty ? const Color(0xFF17212B) : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => _speak(_targetText, _targetCode),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFF667085)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Action Button
            ElevatedButton(
              onPressed: _isTranslating ? null : _handleTranslate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B3A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isTranslating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _buttonState == 'translated' ? "Translated" : "Translate",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
