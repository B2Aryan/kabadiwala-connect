import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Touch-friendly quantity input with increment/decrement stepper and unit toggle
class QuantityInput extends StatelessWidget {
  final double value;
  final String unit;
  final ValueChanged<double> onChanged;
  final ValueChanged<String> onUnitChanged;

  const QuantityInput({
    super.key,
    required this.value,
    required this.unit,
    required this.onChanged,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'वजन / मात्रा (Quantity)',
                  style: AppTypography.titleMedium(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppDimens.xs),
              // Unit segmented buttons
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0C1A13)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Row(
                  children: [
                    _buildUnitOption('kg', 'kg', isDark, activeGreen),
                    _buildUnitOption('pieces', 'pcs', isDark, activeGreen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // Stepper + Large Numeral
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement button
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF1B3828)
                      : const Color(0xFFDCFCE7),
                  foregroundColor: activeGreen,
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.remove_rounded, size: 24),
                onPressed: () {
                  if (value > 1.0) {
                    onChanged(value - 1.0);
                  }
                },
              ),
              const SizedBox(width: AppDimens.xl),

              // Large number display
              Container(
                constraints: const BoxConstraints(minWidth: 90),
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: value % 1 == 0
                        ? value.toInt().toString()
                        : value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF0F172A),
                    ),
                    children: [
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.xl),

              // Increment button
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: activeGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.add_rounded, size: 24),
                onPressed: () => onChanged(value + 1.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitOption(
    String key,
    String label,
    bool isDark,
    Color activeColor,
  ) {
    final isSelected = unit == key;

    return GestureDetector(
      onTap: () => onUnitChanged(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}
