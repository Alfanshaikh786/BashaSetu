import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Navigation Drawer for Bhasha Setu
/// Provides full access to all 17+ pages and modes
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        "ᱥᱟ",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "भाषा | SETU",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "Tribal Languages Platform",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _buildSectionHeader("CORE TRANSLATION"),
                  _buildItem(context, Icons.translate_rounded, "Text-to-Text", "/features/text-to-text"),
                  _buildItem(context, Icons.record_voice_over_rounded, "Voice-to-Voice (S2S)", "/features/speech-to-speech"),
                  _buildItem(context, Icons.mic_none_rounded, "Speech-to-Text (ASR)", "/features/speech-to-text"),
                  _buildItem(context, Icons.volume_up_rounded, "Text-to-Speech (TTS)", "/features/text-to-speech"),
                  _buildItem(context, Icons.document_scanner_rounded, "Document OCR", "/features/ocr"),
                  _buildItem(context, Icons.subtitles_rounded, "Video Subtitle Studio", "/features/video-subtitle"),

                  const SizedBox(height: 12),
                  _buildSectionHeader("SPECIALIZED MODES"),
                  _buildItem(context, Icons.school_rounded, "Learning Studio", "/features/learning-studio"),
                  _buildItem(context, Icons.smartphone_rounded, "Field Mode", "/field-mode"),
                  _buildItem(context, Icons.tv_rounded, "Teacher Projector Mode", "/teacher-mode"),
                  _buildItem(context, Icons.emergency_rounded, "Emergency Medical Mode", "/emergency-mode", isEmergency: true),

                  const SizedBox(height: 12),
                  _buildSectionHeader("RESOURCES & COMMUNITY"),
                  _buildItem(context, Icons.menu_book_rounded, "Multilingual Dictionary", "/resources/dictionary"),
                  _buildItem(context, Icons.verified_user_rounded, "Knowledge Base", "/resources/knowledge-base"),
                  _buildItem(context, Icons.podcasts_rounded, "Vaani Stream", "/vaani-stream"),

                  const SizedBox(height: 12),
                  _buildSectionHeader("SUPPORT & ABOUT"),
                  _buildItem(context, Icons.info_outline_rounded, "About Bhasha Setu", "/about-us"),
                  _buildItem(context, Icons.support_agent_rounded, "Contact Support", "/contact-us"),
                  _buildItem(context, Icons.privacy_tip_outlined, "Privacy Policy", "/privacy-policy"),
                  _buildItem(context, Icons.login_rounded, "Login / Account", "/login"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    bool isEmergency = false,
  }) {
    final isCurrent = ModalRoute.of(context)?.settings.name == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: isCurrent
            ? AppColors.primaryLight
            : (isEmergency ? Colors.red.shade50 : Colors.transparent),
        leading: Icon(
          icon,
          size: 20,
          color: isEmergency
              ? Colors.red.shade700
              : (isCurrent ? AppColors.primary : AppColors.textSecondary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            color: isEmergency
                ? Colors.red.shade700
                : (isCurrent ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
        onTap: () {
          Navigator.pop(context);
          if (!isCurrent) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
