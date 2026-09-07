import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';

/// Clean 4-segment progress bar with checkmark indicators
class LotProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const LotProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final inactiveColor = isDark
        ? const Color(0xFF1F382B)
        : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.xs,
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNum = index + 1;
          final isCompleted = stepNum < currentStep;
          final isCurrent = stepNum == currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? activeColor
                          : inactiveColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                    ),
                  ),
                ),
                if (index < totalSteps - 1) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}
