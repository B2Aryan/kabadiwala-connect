import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clean, friendly typography tailored for high legibility
/// in English, Hindi, and Marathi.
class AppTypography {
  AppTypography._();

  static TextStyle headlineLarge(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 26.0,
      fontWeight: FontWeight.w700,
      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      letterSpacing: -0.5,
    );
  }

  static TextStyle headlineMedium(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      letterSpacing: -0.3,
    );
  }

  static TextStyle titleLarge(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
    );
  }

  static TextStyle titleMedium(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
    );
  }

  static TextStyle bodyLarge(bool isDark) {
    return GoogleFonts.inter(
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
    );
  }

  static TextStyle bodyMedium(bool isDark) {
    return GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: FontWeight.w400,
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
    );
  }

  static TextStyle bodySmall(bool isDark) {
    return GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
    );
  }

  static TextStyle buttonHero(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 0.2,
    );
  }

  static TextStyle buttonHeroSub(bool isDark) {
    return GoogleFonts.inter(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.9),
    );
  }

  static TextStyle priceRate(bool isDark) {
    return GoogleFonts.outfit(
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
    );
  }

  static TextStyle badge(bool isDark) {
    return GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
    );
  }
}
