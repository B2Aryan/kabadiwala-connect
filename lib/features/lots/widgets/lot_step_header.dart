import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';

/// Header showing back button, title, and current step progress
class LotStepHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const LotStepHeader({
    super.key,
    required this.title,
    required this.currentStep,
    this.totalSteps = 4,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            tooltip: 'Back',
          ),
          const SizedBox(width: AppDimens.xs),
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleLarge(isDark)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          // Step pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F3020) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryGreenDark.withValues(alpha: 0.3)
                    : AppColors.primaryGreenLight.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '$currentStep / $totalSteps',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.primaryGreenDark
                    : AppColors.primaryGreenLight,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
        ],
      ),
    );
  }
}
