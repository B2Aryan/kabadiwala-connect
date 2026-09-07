import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/models/material_price_model.dart';

/// Reusable RateRow component for price table items
class RateRow extends StatelessWidget {
  final MaterialPriceModel item;
  final bool isLast;

  const RateRow({super.key, required this.item, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0),
          child: Row(
            children: [
              // Material Name
              Expanded(
                child: Text(
                  langProvider.tr(item.translationKey),
                  style: AppTypography.bodyLarge(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              // Rate Per Kg
              Text(
                '₹${item.ratePerKg.toInt()}/kg',
                style: AppTypography.priceRate(isDark),
              ),
              const SizedBox(width: AppDimens.md),
              // Percentage Badge with Upward Arrow
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.badgeGreenBgDark
                      : AppColors.badgeGreenBgLight,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Text(
                  '↗ +${item.changePercentage}%',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.badgeGreenTextDark
                        : AppColors.badgeGreenTextLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.6,
            color: isDark ? const Color(0xFF1C3024) : const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}
