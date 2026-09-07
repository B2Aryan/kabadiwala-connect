import 'package:flutter/material.dart';

/// Centralized Color Tokens for Kabadiwala Connect
/// Supports both Light and Dark modes matching the design reference.
class AppColors {
  AppColors._();

  // ==================== BRAND CORE ====================
  static const Color primaryGreenLight = Color(0xFF15803D); // Deep Eco Emerald
  static const Color primaryGreenDark = Color(
    0xFF22C55E,
  ); // Electric Bio Emerald

  static const Color primaryDarkShade = Color(0xFF0D5C3A);
  static const Color primaryLightTint = Color(0xFFDCFCE7);

  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberDark = Color(0xFFFBBF24);
  static const Color accentAmberContainerLight = Color(0xFFFEF3C7);
  static const Color accentAmberContainerDark = Color(0xFF2D2305);

  // ==================== LIGHT MODE TOKENS ====================
  static const Color bgLight = Color(0xFFF6F8F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceBorderLight = Color(0xFFE2E8F0);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  static const Color cardShadowLight = Color(0x0C000000);

  // ==================== DARK MODE TOKENS ====================
  static const Color bgDark = Color(0xFF0A130E); // Deep Forest Charcoal
  static const Color surfaceDark = Color(0xFF14231B); // Elevated Forest Slate
  static const Color surfaceBorderDark = Color(
    0xFF1F382B,
  ); // Emerald Border Glow

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  static const Color cardShadowDark = Color(0x33000000);

  // ==================== STATUS & BADGES ====================
  static const Color badgeGreenTextLight = Color(0xFF15803D);
  static const Color badgeGreenBgLight = Color(0xFFDCFCE7);

  static const Color badgeGreenTextDark = Color(0xFF4ADE80);
  static const Color badgeGreenBgDark = Color(0xFF064E3B);
}
