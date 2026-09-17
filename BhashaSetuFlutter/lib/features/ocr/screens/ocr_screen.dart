import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../services/ocr/ocr_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  String _extractedText = '';
  String _translatedText = '';
  double _confidence = 0.0;

  String _sourceLang = 'eng';
  String _targetLang = 'sat';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _isProcessing = true;
          _extractedText = '';
          _translatedText = '';
        });

        final result = await OcrService.instance.processImageAndTranslate(
          imageFile: _selectedImage!,
          sourceLang: _sourceLang,
          targetLang: _targetLang,
        );

        setState(() {
          _extractedText = result['extractedText'] as String? ?? '';
          _translatedText = result['translatedText'] as String? ?? '';
          _confidence = (result['confidence'] as double?) ?? 0.0;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OCR Error: ${e.toString()}")),
        );
      }
    }
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
                  child: const Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Neural Document OCR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text("Scan textbooks, blackboards & government notices", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Camera / Upload Action Bar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text("Take Photo"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                    label: const Text("Pick Gallery"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Image Preview
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: _isProcessing
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text("Neural OCR Processing...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
            ],

            // Extracted Text Card
            if (_extractedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DETECTED TEXT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      _extractedText,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Translated Text Card
            if (_translatedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("OFFLINE TRANSLATION (SANTALI)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                        Text("${(_confidence * 100).toInt()}% Match", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translatedText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
