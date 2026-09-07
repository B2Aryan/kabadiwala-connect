import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Card summarizing lot before creation with edit triggers
class LotReviewCard extends StatelessWidget {
  final List<String> photos;
  final String materialName;
  final double quantity;
  final String unit;
  final double rate;
  final double estimatedValue;
  final String condition;
  final String? notes;
  final VoidCallback onEdit;

  const LotReviewCard({
    super.key,
    required this.photos,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.estimatedValue,
    required this.condition,
    this.notes,
    required this.onEdit,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'लॉट सारांश (Lot Summary)',
                  style: AppTypography.titleMedium(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: activeGreen,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: AppDimens.md),

          // Details List
          _buildItem('सामग्री (Material)', materialName, isDark),
          const SizedBox(height: AppDimens.sm),
          _buildItem(
            'मात्रा (Quantity)',
            '${quantity % 1 == 0 ? quantity.toInt() : quantity} $unit',
            isDark,
          ),
          const SizedBox(height: AppDimens.sm),
          _buildItem('स्थिति (Condition)', _formatCondition(condition), isDark),
          const SizedBox(height: AppDimens.sm),
          _buildItem('अनुमानित दर (Rate)', '₹${rate.toInt()}/$unit', isDark),
          const SizedBox(height: AppDimens.sm),
          _buildItem('फ़ोटो (Photos)', '${photos.length} attached', isDark),
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.sm),
            _buildItem('टिप्पणी (Notes)', notes!, isDark),
          ],

          const SizedBox(height: AppDimens.md),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: AppDimens.md),

          // Highlighted Value
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF10281C) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(color: activeGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'अनुमानित भुगतान',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFF166534),
                      ),
                    ),
                    const Text(
                      'Estimated Total',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                Text(
                  '₹${estimatedValue.toInt()}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: activeGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String val, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMedium(isDark))),
        const SizedBox(width: AppDimens.xs),
        Text(
          val,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  String _formatCondition(String cond) {
    switch (cond) {
      case 'good':
        return 'ठीक (Working/Intact)';
      case 'broken':
        return 'टूटा हुआ (Damaged)';
      case 'scrap':
        return 'खराब (Scrap/Parts)';
      default:
        return cond;
    }
  }
}
