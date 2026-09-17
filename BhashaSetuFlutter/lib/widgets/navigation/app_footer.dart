import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    "ᱥᱟ",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "भाषा | SETU",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "An offline-first multilingual translation and pedagogical ecosystem empowering teachers, doctors, and tribal students across India.",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLink(context, "Text-to-Text", "/features/text-to-text"),
              _buildLink(context, "Learning Studio", "/features/learning-studio"),
              _buildLink(context, "Dictionary", "/resources/dictionary"),
              _buildLink(context, "Emergency Mode", "/emergency-mode"),
              _buildLink(context, "About Us", "/about-us"),
              _buildLink(context, "Privacy Policy", "/privacy-policy"),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          const Text(
            "© 2026 Bhasha Setu. Smart India Hackathon (SIH) Initiative.\n100% Offline Capable • Zero Network Dependency.",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String text, String route) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
