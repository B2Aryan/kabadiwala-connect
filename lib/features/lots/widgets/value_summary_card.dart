import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Card showing breakdown: Material, Quantity, Rate, Estimated Value, and disclaimer
class ValueSummaryCard extends StatelessWidget {
  final String materialName;
  final double quantity;
  final String unit;
  final double rate;
  final double estimatedValue;

  const ValueSummaryCard({
    super.key,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.estimatedValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F3020)
                      : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: activeGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Text(
                  'मूल्य गणना (Price Calculation)',
                  style: AppTypography.titleMedium(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: AppDimens.md),

          // Row 1: Material
          _buildRow('सामग्री (Material)', materialName, isDark),
          const SizedBox(height: AppDimens.sm),

          // Row 2: Quantity
          _buildRow(
            'मात्रा (Quantity)',
            '${quantity % 1 == 0 ? quantity.toInt() : quantity} $unit',
            isDark,
          ),
          const SizedBox(height: AppDimens.sm),

          // Row 3: Rate
          _buildRow(
            'अनुमानित दर (Demo Rate)',
            '₹${rate.toInt()}/$unit',
            isDark,
          ),
          const SizedBox(height: AppDimens.md),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: AppDimens.md),

          // Estimated Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'अनुमानित मूल्य\n(Estimated Value)',
                style: AppTypography.titleMedium(isDark)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '₹${estimatedValue.toInt()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: activeGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // Disclaimer note
          Container(
            padding: const EdgeInsets.all(AppDimens.sm),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2007) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: AppDimens.xs),
                Expanded(
                  child: Text(
                    'यह केवल अनुमानित डेमो मूल्य है। अंतिम कीमत Recycler भौतिक निरीक्षण के बाद तय होगी।',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium(isDark)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
