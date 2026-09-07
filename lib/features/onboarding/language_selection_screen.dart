import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/eco_vectors.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _onLanguageSelected(BuildContext context, AppLanguage language) {
    Provider.of<LanguageProvider>(context, listen: false).setLanguage(language);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          // Quick theme toggle button for demonstration & review
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark
                  ? const Color(0xFFFBBF24)
                  : AppColors.primaryGreenLight,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          const SizedBox(width: AppDimens.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimens.md),
            // Header
            Text(
              langProvider.tr('chooseLanguage'),
              style: AppTypography.headlineMedium(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              langProvider.tr('letsGetStarted'),
              style: AppTypography.bodyLarge(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.xxl),

            // Language Cards List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
              child: Column(
                children: [
                  // 1. Hindi
                  _buildLanguageOptionCard(
                    context: context,
                    isDark: isDark,
                    isSelected:
                        langProvider.currentLanguage == AppLanguage.hindi,
                    icon: IndiaGatewayIcon(isDark: isDark),
                    nativeTitle: 'हिन्दी',
                    subtitle: 'Hindi',
                    onTap: () =>
                        _onLanguageSelected(context, AppLanguage.hindi),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // 2. Marathi
                  _buildLanguageOptionCard(
                    context: context,
                    isDark: isDark,
                    isSelected:
                        langProvider.currentLanguage == AppLanguage.marathi,
                    icon: MaharashtraFortIcon(isDark: isDark),
                    nativeTitle: 'मराठी',
                    subtitle: 'Marathi',
                    onTap: () =>
                        _onLanguageSelected(context, AppLanguage.marathi),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // 3. English
                  _buildLanguageOptionCard(
                    context: context,
                    isDark: isDark,
                    isSelected:
                        langProvider.currentLanguage == AppLanguage.english,
                    icon: EnglishGlobeIcon(isDark: isDark),
                    nativeTitle: 'English',
                    subtitle: 'English',
                    onTap: () =>
                        _onLanguageSelected(context, AppLanguage.english),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Green Earth Illustration with Mission Tagline
            GreenEarthBanner(
              height: 200,
              isDark: isDark,
              bannerText: langProvider.tr('cleanIndiaBanner'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOptionCard({
    required BuildContext context,
    required bool isDark,
    required bool isSelected,
    required Widget icon,
    required String nativeTitle,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final activeBorderColor = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.md,
      ),
      borderColor: isSelected ? activeBorderColor : null,
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppDimens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeTitle,
                  style: AppTypography.titleLarge(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                Text(subtitle, style: AppTypography.bodyMedium(isDark)),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }
}
