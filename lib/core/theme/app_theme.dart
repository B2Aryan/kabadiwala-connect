import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryGreen = AppColors.primaryGreenLight;
  static const Color cardDark = AppColors.surfaceDark;
  static const Color cardDarkBorder = AppColors.surfaceBorderDark;
  static const Color borderGrey = AppColors.surfaceBorderLight;
  static const Color textDark = AppColors.textPrimaryLight;
  static const Color textMuted = AppColors.textSecondaryLight;
  static const Color textMutedDark = AppColors.textSecondaryDark;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreenLight,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLightTint,
        onPrimaryContainer: AppColors.primaryDarkShade,
        secondary: AppColors.accentAmber,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        outline: AppColors.surfaceBorderLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          side: const BorderSide(
            color: AppColors.surfaceBorderLight,
            width: AppDimens.borderWidthStandard,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreenDark,
        onPrimary: Color(0xFF052E16),
        primaryContainer: Color(0xFF0D3320),
        onPrimaryContainer: AppColors.primaryGreenDark,
        secondary: AppColors.accentAmberDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        outline: AppColors.surfaceBorderDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          side: const BorderSide(
            color: AppColors.surfaceBorderDark,
            width: AppDimens.borderWidthStandard,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
