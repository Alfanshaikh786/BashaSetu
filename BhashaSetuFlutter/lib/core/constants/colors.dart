import 'package:flutter/material.dart';

/// Central Design Palette for Bhasha Setu
/// Matched exactly to the React production design tokens
class AppColors {
  // Brand Palette
  static const Color primary = Color(0xFF238B45);       // Primary green CTA, active badges
  static const Color primaryDark = Color(0xFF176B3A);   // Hover, pressed state, deep green
  static const Color primaryLight = Color(0xFFEAF5EA);  // Badges, pill backgrounds, icon circles
  static const Color veryLightGreen = Color(0xFFF4FAF3);// Subtle card tints, hover accents

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FBF7);    // Canvas background
  static const Color surface = Color(0xFFFFFFFF);       // Cards, modals, pill navbar shell
  static const Color surfaceSubtle = Color(0xFFF1F7F0); // Subtle contrast containers

  // Typography
  static const Color textPrimary = Color(0xFF17212B);   // High-contrast primary headings and body
  static const Color textSecondary = Color(0xFF667085); // Subtitles, captions, metadata
  static const Color textMuted = Color(0xFF98A2B3);     // Disabled, placeholders

  // Borders & Accents
  static const Color border = Color(0xFFD5E8D5);        // 1px clean rounded border
  static const Color borderSubtle = Color(0xFFE5EFE4);  // Inner divider lines

  // Status & Tiers
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFF04438);
  static const Color info = Color(0xFF0BA5EC);
}
