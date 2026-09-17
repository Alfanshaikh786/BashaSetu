import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
            // Title
            const Text("About Bhasha Setu (भाषा | SETU)", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text("Bridging Indigenous Tribal Languages Through Offline-First Pedagogical AI", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),

            // Card 1: The Problem & Solution
            _buildCard(
              "Our Mission & NEP 2020 Vision",
              "Across India's tribal belts, 70%+ of primary school tribal children struggle with non-native state languages, contributing to high dropout rates. Bhasha Setu provides an offline-first AI translation and teaching bridge that enables migrant teachers and healthcare workers to communicate fluently in Santali (Ol Chiki), Gondi, Mundari, and Ho.",
              Icons.school_rounded,
            ),
            const SizedBox(height: 16),

            // Card 2: 100% Offline Guarantee
            _buildCard(
              "Zero-Network Architecture",
              "Interior tribal schools often lack cellular networks. Bhasha Setu runs entirely on-device using a local SQLite database (6,780 parallel verified entries), local neural OCR, and in-memory phonetic speech engines with zero bytes transmitted over the cloud.",
              Icons.wifi_off_rounded,
            ),
            const SizedBox(height: 16),

            // Card 3: Institutional Background
            _buildCard(
              "Smart India Hackathon (SIH) Initiative",
              "Developed by Alfan Shaikh and team at Sahyadri College of Engineering & Management, Mangaluru, under Ministry of Tribal Affairs problem statements.",
              Icons.emoji_events_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
