import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/language.dart';
import '../../../data/models/translation_result.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

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
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.translate_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Text-to-Text Translation",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      "Offline multi-script verified translations",
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Language Selector Bar ──
            _buildLanguageSelectorBar(),
            const SizedBox(height: 16),

            // ── Input Card ──
            _buildInputCard(),
            const SizedBox(height: 16),

            // ── Output Card ──
            if (_result != null) _buildOutputCard(),

            // ── Virtual Ol Chiki Keyboard ──
            if (_showVirtualKeyboard) ...[
              const SizedBox(height: 16),
              _buildVirtualKeyboard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Source Language Dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sourceLang,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              items: supportedLanguages.map((l) {
                return DropdownMenuItem(
                  value: l.code,
                  child: Text(
                    "${l.name} (${l.script})",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _sourceLang = val);
                  _handleTranslate();
                }
              },
            ),
          ),

          // Swap Button
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
            onPressed: _swapLanguages,
          ),

          // Target Language Dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _targetLang,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              items: supportedLanguages.map((l) {
                return DropdownMenuItem(
                  value: l.code,
                  child: Text(
                    "${l.name} (${l.script})",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                );
              }).toList(),
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
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INPUT TEXT (${_inputController.text.length} chars)",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  if (_sourceLang == 'sat')
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _showVirtualKeyboard = !_showVirtualKeyboard);
                      },
                      icon: const Icon(Icons.keyboard_alt_outlined, size: 16),
                      label: Text(_showVirtualKeyboard ? "Hide Keys" : "Ol Chiki Keys", style: const TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  if (_inputController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                      onPressed: () {
                        _inputController.clear();
                        setState(() => _result = null);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _inputController,
            maxLines: 4,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              hintText: "Type text or sentence here...",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              fillColor: Colors.transparent,
            ),
            onChanged: (_) => _handleTranslate(),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTranslating ? null : _handleTranslate,
              icon: _isTranslating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.translate_rounded, size: 18),
              label: const Text("Translate Offline"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputCard() {
    final res = _result!;
    final isUnavailable = res.reliability == TranslationStatus.unavailable;

    return Container(
      decoration: BoxDecoration(
        color: isUnavailable ? Colors.amber.shade50 : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnavailable ? Colors.amber.shade300 : AppColors.border,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Reliability Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnavailable ? Colors.amber.shade200 : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isUnavailable ? "UNAVAILABLE" : "VERIFIED (${(res.confidence * 100).toInt()}%)",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isUnavailable ? Colors.brown : AppColors.primaryDark,
                  ),
                ),
              ),

              // Action buttons
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: res.targetText));
                      setState(() => _copied = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) setState(() => _copied = false);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppColors.primary),
                    onPressed: () {
                      TtsService.instance.speak(text: res.targetText, langCode: _targetLang);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Output Text
          Text(
            res.targetText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isUnavailable ? Colors.brown.shade900 : AppColors.primaryDark,
            ),
          ),

          if (res.roman != null && res.roman!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Phonetic: ${res.roman}",
              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
          ],

          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                "Source: ${res.provider}",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualKeyboard() {
    return Container(
      padding: const EdgeInsets.all(12),
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
            children: const [
              Text("Ol Chiki Virtual Keyboard", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text("Pandit Raghunath Murmu Script", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
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
                    color: AppColors.veryLightGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      key,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
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
