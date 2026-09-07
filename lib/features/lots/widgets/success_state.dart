import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../features/lots/models/ewaste_lot.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Full success state card with check animation, Lot ID, details, and action CTAs
class SuccessState extends StatelessWidget {
  final EwasteLot lot;
  final VoidCallback onFindRecyclers;
  final VoidCallback onViewLots;

  const SuccessState({
    super.key,
    required this.lot,
    required this.onFindRecyclers,
    required this.onViewLots,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Emblem with Pulse Circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F3020)
                    : const Color(0xFFDCFCE7),
                shape: BoxShape.circle,
                border: Border.all(color: activeGreen, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: activeGreen.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 56,
                color: activeGreen,
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // Title
            Text(
              'लॉट सफलतापूर्वक बनाया गया!',
              style: AppTypography.headlineMedium(isDark)
                  .copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Lot Created Successfully',
              style: AppTypography.bodyMedium(isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.xl),

            // Lot Info Card
            AppCard(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                children: [
                  // Lot ID Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF162A1F)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      border: Border.all(
                        color: activeGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'LOT ID: ${lot.id}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: activeGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                  const Divider(height: 1, thickness: 0.6),
                  const SizedBox(height: AppDimens.md),

                  _buildSuccessRow(
                    'सामग्री (Material)',
                    lot.materialName,
                    isDark,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  _buildSuccessRow(
                    'मात्रा (Quantity)',
                    '${lot.quantity % 1 == 0 ? lot.quantity.toInt() : lot.quantity} ${lot.unit}',
                    isDark,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  _buildSuccessRow(
                    'अनुमानित मूल्य (Value)',
                    '₹${lot.estimatedValue.toInt()}',
                    isDark,
                    isHighlight: true,
                    activeColor: activeGreen,
                  ),
                  const SizedBox(height: AppDimens.sm),
                  _buildSuccessRow('स्थिति (Status)', lot.status, isDark),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xl),

            // Primary CTA: Find Nearby Recyclers
            PrimaryButton(
              title: 'पास के Recycler खोजें',
              subtitle: 'Find Nearby Recyclers',
              icon: const Icon(
                Icons.alt_route_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: onFindRecyclers,
            ),
            const SizedBox(height: AppDimens.md),

            // Secondary CTA: View My Lots
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeightStandard,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? Colors.white
                      : AppColors.primaryDarkShade,
                  side: BorderSide(
                    color: isDark
                        ? AppColors.surfaceBorderDark
                        : AppColors.surfaceBorderLight,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                ),
                onPressed: onViewLots,
                icon: const Icon(Icons.inventory_2_outlined, size: 20),
                label: const Text(
                  'मेरे लॉट देखें (View My Lots)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessRow(
    String label,
    String val,
    bool isDark, {
    bool isHighlight = false,
    Color? activeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMedium(isDark))),
        const SizedBox(width: AppDimens.xs),
        Text(
          val,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 13.5,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight
                ? activeColor
                : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
