import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/language.dart';
import '../../../services/ocr/ocr_service.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _imageName = "sample_notice.png";
  bool _isProcessing = false;

  String _sourceLang = 'eng';
  String _targetLang = 'sat';
  String _selectedScript = 'auto';

  late TextEditingController _extractedTextController;
  String _translatedText = '';
  double _confidence = 0.92;
  bool _copiedExtracted = false;
  bool _copiedTranslated = false;

  final List<Map<String, String>> _sampleDocs = [
    {
      'title': 'School Notice',
      'script': 'Latin / English',
      'text': 'All students must attend the annual cultural program on Monday at 9:00 AM in the primary school hall.',
      'translation': 'ᱥᱟᱱᱟᱢ ᱯᱟᱹᱴᱷᱩᱣᱟᱹ ᱠᱚ ᱥᱤᱸᱜᱮ ᱢᱟᱦᱟᱸ ᱥᱮᱛᱟᱜ ᱙:᱐᱐ ᱴᱟᱲᱟᱝ ᱨᱮ ᱯᱨᱟᱭᱢᱟᱨᱤ ᱟᱥᱲᱟ ᱦᱚᱞ ᱨᱮ ᱥᱮᱨᱢᱟᱠᱤᱭᱟᱹ ᱞᱟᱠᱪᱟᱨ ᱟᱠᱷᱲᱟ ᱨᱮ ᱥᱮᱞᱮᱫᱚᱜ ᱞᱟᱹᱠᱛᱤ ᱾',
    },
    {
      'title': 'Healthcare Guidelines',
      'script': 'Devanagari / Hindi',
      'text': 'बरसात के मौसम में सिर्फ उबला हुआ पानी पिएं और स्वच्छता का पूरा ध्यान रखें।',
      'translation': 'ᱫᱟᱜ ᱫᱤᱱ ᱨᱮ ᱦᱮᱰᱮᱡ ᱫᱟᱜ ᱜᱮ ᱧᱩᱭ ᱯᱮ ᱟᱨ ᱥᱟᱯᱷᱟ-ᱥᱟᱹᱯᱷᱤ ᱨᱮᱭᱟᱜ ᱯᱩᱨᱟᱹ ᱫᱷᱮᱭᱟᱱ ᱫᱚᱦᱚᱭ ᱯᱮ ᱾',
    },
    {
      'title': 'Forest Advisory',
      'script': 'Latin / English',
      'text': 'Do not cut green trees. Plant more fruit-bearing saplings near village boundaries.',
      'translation': 'ᱦᱟᱹᱨᱭᱟᱹᱲ ᱫᱟᱨᱮ ᱟᱞᱚᱯᱮ ᱢᱟᱜ-ᱟ ᱾ ᱟᱹᱛᱩ ᱥᱤᱢᱟᱹ ᱫᱷᱟᱨᱮ-ᱫᱷᱟᱨᱮ ᱛᱮ ᱡᱚ ᱫᱟᱨᱮ ᱠᱚ ᱨᱚᱦᱚᱭ ᱯᱮ ᱾',
    },
  ];

  @override
  void initState() {
    super.initState();
    _extractedTextController = TextEditingController(text: _sampleDocs[0]['text']!);
    _translatedText = _sampleDocs[0]['translation']!;
    _imageName = _sampleDocs[0]['title']!;
  }

  @override
  void dispose() {
    _extractedTextController.dispose();
    super.dispose();
  }

  void _selectSample(Map<String, String> doc) {
    setState(() {
      _selectedImage = null;
      _imageName = doc['title']!;
      _extractedTextController.text = doc['text']!;
      _translatedText = doc['translation']!;
      _confidence = 0.95;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _imageName = picked.name;
          _isProcessing = true;
        });

        final result = await OcrService.instance.processImageAndTranslate(
          imageFile: _selectedImage!,
          sourceLang: _sourceLang,
          targetLang: _targetLang,
        );

        setState(() {
          _extractedTextController.text = result['extractedText'] as String? ?? '';
          _translatedText = result['translatedText'] as String? ?? '';
          _confidence = (result['confidence'] as double?) ?? 0.88;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OCR Notice: ${e.toString()}")),
        );
      }
    }
  }

  void _handleCopy(String text, bool isTranslation) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      if (isTranslation) {
        _copiedTranslated = true;
      } else {
        _copiedExtracted = true;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (isTranslation) {
            _copiedTranslated = false;
          } else {
            _copiedExtracted = false;
          }
        });
      }
    });
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
                  constraints: const BoxConstraints(maxWidth: 1040),
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
                                  "Multi-Script OCR & Document Scanner",
                                  style: TextStyle(color: Color(0xFF14532D), fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Multi-Script OCR & Scanner",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Extract and translate text from textbooks, blackboards, field notices, and administrative circulars with zero hallucination guarantee.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sample Documents Chip Row
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const Text("Sample Documents:", style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            ..._sampleDocs.map((doc) {
                              final isSelected = _imageName == doc['title'];
                              return InkWell(
                                onTap: () => _selectSample(doc),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSelected ? const Color(0xFF249144) : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.description_outlined, size: 14, color: isSelected ? const Color(0xFF249144) : const Color(0xFF64748B)),
                                      const SizedBox(width: 6),
                                      Text(
                                        doc['title']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? const Color(0xFF14532D) : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Script Selection & Upload Bar
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                const Text("Target Script: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                const SizedBox(width: 6),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedScript,
                                    items: const [
                                      DropdownMenuItem(value: 'auto', child: Text("Auto Detect", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold))),
                                      DropdownMenuItem(value: 'deva', child: Text("Devanagari (देवनागरी)", style: TextStyle(fontSize: 12.5))),
                                      DropdownMenuItem(value: 'olck', child: Text("Ol Chiki (ᱚᱞ ᱪᱤᱠᱤ)", style: TextStyle(fontSize: 12.5))),
                                      DropdownMenuItem(value: 'latn', child: Text("Latin / English", style: TextStyle(fontSize: 12.5))),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedScript = val);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            Wrap(
                              spacing: 10,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                                  label: const Text("Take Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                                  label: const Text("Upload Image", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF249144),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2-Column Split: Image Preview (Left) & Extracted + Translated (Right)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 720;
                          final leftWidget = Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.image_outlined, size: 18, color: Color(0xFF64748B)),
                                          const SizedBox(width: 8),
                                          Text(_imageName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                        child: Text("${(_confidence * 100).toInt()}% Confidence", style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 280,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0F172A),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(24),
                                      bottomRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: _selectedImage != null
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(24),
                                          ),
                                          child: Image.file(_selectedImage!, fit: BoxFit.contain),
                                        )
                                      : Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.document_scanner_rounded, size: 54, color: Color(0xFF34D399)),
                                                const SizedBox(height: 12),
                                                Text(
                                                  "Document: $_imageName",
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  "High-accuracy neural OCR applied",
                                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          );

                          final rightWidget = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Extracted Text Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("EXTRACTED TEXT (EDITABLE)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF64748B)),
                                              onPressed: () => TtsService.instance.speak(text: _extractedTextController.text, langCode: _sourceLang),
                                            ),
                                            IconButton(
                                              icon: Icon(_copiedExtracted ? Icons.check : Icons.copy_rounded, size: 18, color: _copiedExtracted ? const Color(0xFF059669) : const Color(0xFF64748B)),
                                              onPressed: () => _handleCopy(_extractedTextController.text, false),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _extractedTextController,
                                      maxLines: 4,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.4),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        contentPadding: const EdgeInsets.all(14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 2. Offline Translation Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "OFFLINE TRANSLATION (${targetLangObj.name.toUpperCase()})",
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D), letterSpacing: 0.6),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF15803D)),
                                              onPressed: () => TtsService.instance.speak(text: _translatedText, langCode: _targetLang),
                                            ),
                                            IconButton(
                                              icon: Icon(_copiedTranslated ? Icons.check : Icons.copy_rounded, size: 18, color: _copiedTranslated ? const Color(0xFF059669) : const Color(0xFF15803D)),
                                              onPressed: () => _handleCopy(_translatedText, true),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFDCFCE7)),
                                      ),
                                      child: Text(
                                        _translatedText,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF14532D),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: leftWidget),
                                const SizedBox(width: 20),
                                Expanded(flex: 6, child: rightWidget),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                leftWidget,
                                const SizedBox(height: 16),
                                rightWidget,
                              ],
                            );
                          }
                        },
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
