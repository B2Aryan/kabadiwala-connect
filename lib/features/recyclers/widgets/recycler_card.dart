import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../lots/models/ewaste_lot.dart';
import '../models/recycler.dart';

/// Clean, responsive card displaying a mock recycler facility.
class RecyclerCard extends StatelessWidget {
  final Recycler recycler;
  final EwasteLot? matchingLot;
  final VoidCallback onTap;

  const RecyclerCard({
    super.key,
    required this.recycler,
    this.matchingLot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final langProvider = LanguageProvider.of(context);

    final isGreatMatch =
        matchingLot != null &&
        recycler.acceptsMaterial(matchingLot!.materialKey);

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Facility Icon, Name, Demo Tag & Distance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F3020)
                      : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activeGreen.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: activeGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recycler.name,
                            style: AppTypography.titleMedium(isDark)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        // Demo indicator badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF332005)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSm,
                            ),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            langProvider.tr('demoNoticeBadge'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          langProvider.tr(
                            'distanceAway',
                            params: {
                              'distance': recycler.distanceKm.toString(),
                            },
                          ),
                          style: AppTypography.bodySmall(isDark),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        const Text(
                          '•',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          recycler.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Matching Lot banner (if lot passed)
          if (matchingLot != null) ...[
            const SizedBox(height: AppDimens.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isGreatMatch
                    ? (isDark
                          ? const Color(0xFF132A1C)
                          : const Color(0xFFDCFCE7))
                    : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                border: Border.all(
                  color: isGreatMatch
                      ? activeGreen.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isGreatMatch
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 15,
                    color: isGreatMatch ? activeGreen : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      recycler.matchReasonFor(matchingLot),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isGreatMatch
                            ? activeGreen
                            : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimens.md),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: AppDimens.md),

          // Accepted Materials chips & Pickup badge
          Row(
            children: [
              // Pickup Availability Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: recycler.pickupAvailable
                      ? (isDark
                            ? AppColors.badgeGreenBgDark
                            : AppColors.badgeGreenBgLight)
                      : (isDark
                            ? const Color(0xFF261D15)
                            : const Color(0xFFFFFBEB)),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  border: Border.all(
                    color: recycler.pickupAvailable
                        ? activeGreen.withValues(alpha: 0.4)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      recycler.pickupAvailable
                          ? Icons.local_shipping_outlined
                          : Icons.store_outlined,
                      size: 13,
                      color: recycler.pickupAvailable
                          ? (isDark
                                ? AppColors.badgeGreenTextDark
                                : AppColors.badgeGreenTextLight)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recycler.pickupAvailable
                          ? langProvider.tr('pickupAvailable')
                          : langProvider.tr('dropOffOnly'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: recycler.pickupAvailable
                            ? (isDark
                                  ? AppColors.badgeGreenTextDark
                                  : AppColors.badgeGreenTextLight)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              // Materials summary label
              Expanded(
                child: Text(
                  recycler.acceptedMaterials
                      .map((m) => m[0].toUpperCase() + m.substring(1))
                      .join(', '),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // Action Button: View Details
          SizedBox(
            width: double.infinity,
            height: AppDimens.buttonHeightStandard,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: activeGreen,
                side: BorderSide(color: activeGreen, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
              ),
              onPressed: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    langProvider.tr('viewDetails'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
