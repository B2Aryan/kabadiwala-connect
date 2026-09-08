import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/language_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/repositories/mock_repository.dart';
import '../../shared/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collector = MockRepository.currentCollector;
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रोफाइल (Profile)'),
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            children: [
              // Avatar & Name Card
              AppCard(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF163826)
                            : const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.primaryGreenDark
                              : AppColors.primaryGreenLight,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: isDark
                              ? AppColors.primaryGreenDark
                              : AppColors.primaryGreenLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    Text(
                      collector.name,
                      style: AppTypography.headlineMedium(isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collector.id,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.primaryGreenDark
                            : AppColors.primaryGreenLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${collector.phone} • ${collector.city}',
                      style: AppTypography.bodyMedium(isDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // Settings Items
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDark
                            ? const Color(0xFFFBBF24)
                            : AppColors.primaryGreenLight,
                      ),
                      title: Text(
                        'Appearance: ${isDark ? "Dark Mode" : "Light Mode"}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeThumbColor: AppColors.primaryGreenDark,
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.6),
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.translate_rounded,
                          color: isDark
                              ? AppColors.primaryGreenDark
                              : AppColors.primaryGreenLight,
                        ),
                        title: Text(
                          'Language: ${langProvider.currentLanguage.nativeName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        subtitle: const Text('हिन्दी • मराठी • English'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () =>
                            _showLanguagePicker(context, langProvider, isDark),
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.6),
                    ListTile(
                      leading: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF10B981),
                      ),
                      title: Text(
                        'SIH 2026 Verification Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFF1F5F9)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: const Text('Authorized Kabadiwala ID Active'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    LanguageProvider langProvider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLg),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                  child: Text(
                    'भाषा चुनें / Select Language',
                    style: AppTypography.titleLarge(isDark)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                for (final lang in AppLanguage.values)
                  ListTile(
                    title: Text(
                      lang.nativeName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(lang.englishName),
                    trailing: langProvider.currentLanguage == lang
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: isDark
                                ? AppColors.primaryGreenDark
                                : AppColors.primaryGreenLight,
                          )
                        : null,
                    onTap: () async {
                      await langProvider.setLanguage(lang, markSelected: true);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
