import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../shared/widgets/app_card.dart';

/// Reusable EcoMotivationBanner / Impact Card component
class EcoMotivationBanner extends StatelessWidget {
  const EcoMotivationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.md),
      backgroundColor: isDark
          ? const Color(0xFF132018)
          : const Color(0xFFFCFDFB),
      child: Row(
        children: [
          // Glowing lightbulb in circle
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accentAmberContainerDark
                  : AppColors.accentAmberContainerLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.accentAmberDark.withValues(alpha: 0.25)
                      : AppColors.accentAmber.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: isDark ? AppColors.accentAmberDark : AppColors.accentAmber,
              size: 26,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langProvider.tr('ecoTipTitle'),
                  style: AppTypography.titleMedium(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  langProvider.tr('ecoTipSub'),
                  style: AppTypography.bodyMedium(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
