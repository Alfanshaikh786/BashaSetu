import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../services/api/api_client.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController(text: ApiClient.instance.baseUrl);
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    await ApiClient.instance.submitFeedback(
      sourceText: "User Contact / Linguistic Suggestion",
      targetText: text,
      sourceLang: "user",
      targetLang: "feedback",
      rating: 5,
      suggestion: _nameController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
      _feedbackController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thank you! Feedback recorded for tribal linguistic review."),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contact & Linguistic Feedback", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text("Suggest new words, report dialect nuances, or configure edge backend.", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Feedback Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Submit a Translation Suggestion", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Your Name & School / Hamlet",
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Linguistic feedback or missing word...",
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      child: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text("Submit Feedback"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Configurable Backend Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Edge FastAPI Backend Configuration", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 6),
                  const Text("Configure server address for optional sync (10.0.2.2:5000 for emulator, LAN IP for phone).", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiUrlController,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      labelText: "Backend Base URL",
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      ApiClient.instance.setBaseUrl(_apiUrlController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Backend URL set to ${_apiUrlController.text.trim()}!")),
                      );
                    },
                    child: const Text("Save Backend URL"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
