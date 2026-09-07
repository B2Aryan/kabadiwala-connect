import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/theme_provider.dart';

/// Reusable AppHeader component for Home Dashboard top bar
class AppHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const AppHeader({super.key, required this.onNotificationTap});

  void _showLanguageSelectionSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.lg,
            vertical: AppDimens.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimens.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.sm,
                  vertical: AppDimens.xs,
                ),
                child: Text(
                  langProvider.tr('chooseLanguage'),
                  style: AppTypography.titleLarge(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              _buildLangTile(
                ctx,
                langProvider,
                AppLanguage.english,
                'English',
                'English',
                isDark,
              ),
              _buildLangTile(
                ctx,
                langProvider,
                AppLanguage.hindi,
                'हिन्दी',
                'Hindi',
                isDark,
              ),
              _buildLangTile(
                ctx,
                langProvider,
                AppLanguage.marathi,
                'मराठी',
                'Marathi',
                isDark,
              ),
              const SizedBox(height: AppDimens.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangTile(
    BuildContext context,
    LanguageProvider langProvider,
    AppLanguage lang,
    String nativeName,
    String engName,
    bool isDark,
  ) {
    final isSelected = langProvider.currentLanguage == lang;
    final activeColor = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return ListTile(
      onTap: () {
        langProvider.setLanguage(lang);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      tileColor: isSelected
          ? (isDark ? const Color(0xFF162A1F) : const Color(0xFFE8F5E9))
          : null,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1A3024) : const Color(0xFFE2E8F0)),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            lang.code.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
      title: Text(
        nativeName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A)),
        ),
      ),
      subtitle: Text(
        engName,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: activeColor)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.sm,
      ),
      child: Row(
        children: [
          // Collector Avatar
          _buildCollectorAvatar(isDark),
          const SizedBox(width: AppDimens.md),

          // Greeting & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langProvider.tr('greeting'),
                  style: AppTypography.titleLarge(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  langProvider.tr('whatToSellToday'),
                  style: AppTypography.bodyMedium(isDark),
                ),
              ],
            ),
          ),

          // Language Selector Button
          InkWell(
            onTap: () => _showLanguageSelectionSheet(context),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF162A1F)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF244833)
                      : const Color(0xFFC8E6C9),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    langProvider.currentLanguage.code.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.primaryGreenDark
                          : AppColors.primaryGreenLight,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.primaryGreenDark
                        : AppColors.primaryGreenLight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppDimens.xs),

          // Theme Toggle Button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark
                  ? const Color(0xFFFBBF24)
                  : AppColors.primaryGreenLight,
              size: 22,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),

          // Notification Bell Icon with Orange Alert Indicator
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF1E293B),
                  size: 24,
                ),
                onPressed: onNotificationTap,
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorAvatar(bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF163826) : const Color(0xFFDCFCE7),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? AppColors.primaryGreenDark
              : AppColors.primaryGreenLight,
          width: 1.5,
        ),
      ),
      child: Center(
        child: ClipOval(
          child: Icon(
            Icons.person_rounded,
            size: 32,
            color: isDark
                ? AppColors.primaryGreenDark
                : AppColors.primaryGreenLight,
          ),
        ),
      ),
    );
  }
}
