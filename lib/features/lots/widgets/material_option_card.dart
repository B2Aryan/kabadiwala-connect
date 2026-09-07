import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Selectable material card (Copper, Aluminium, E-Waste, Other)
class MaterialOptionCard extends StatelessWidget {
  final String title;
  final String rateText;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const MaterialOptionCard({
    super.key,
    required this.title,
    required this.rateText,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.md,
        horizontal: AppDimens.md,
      ),
      borderColor: isSelected ? activeGreen : null,
      backgroundColor: isSelected
          ? (isDark ? const Color(0xFF132A1C) : const Color(0xFFF0FDF4))
          : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? activeGreen
                  : (isDark
                        ? const Color(0xFF1B3526)
                        : const Color(0xFFE2E8F0)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569)),
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium(isDark).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                Text(
                  rateText,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? activeGreen
                    : (isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeGreen,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
