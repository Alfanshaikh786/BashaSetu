import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
            const Text("Privacy Policy & Cultural Ethics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text("Zero Cloud Logging • Tribal Sovereignty • Student Data Protection", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            _buildSection(
              "1. Zero Cloud LLM Data Transfer",
              "Bhasha Setu does not transmit classroom audio, student speech, or user translations to third-party commercial cloud AI providers (such as OpenAI or Google Cloud). All translation, SQLite queries, and OCR processing occur strictly inside the device's sandbox.",
            ),
            const SizedBox(height: 14),

            _buildSection(
              "2. Audio and Microphone Telemetry",
              "Audio captured during Speech-to-Text or Voice-to-Voice turns is processed in volatile device RAM and discarded immediately after phonetic tokenization. No raw acoustic recordings are saved to external servers.",
            ),
            const SizedBox(height: 14),

            _buildSection(
              "3. Indigenous Cultural Sovereignty",
              "All folklore, tribal idioms, and Ol Chiki orthography indexed in Bhasha Setu belong to the respective indigenous communities. The platform serves as an open pedagogical bridge aligned with National Education Policy (NEP 2020) guidelines.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
