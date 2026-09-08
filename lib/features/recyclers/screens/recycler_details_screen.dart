import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../lots/models/ewaste_lot.dart';
import '../../lots/services/lot_provider.dart';
import '../models/recycler.dart';
import '../services/recycler_provider.dart';
import '../widgets/request_handover_modal.dart';

class RecyclerDetailsScreen extends StatelessWidget {
  final Recycler recycler;
  final EwasteLot? matchingLot;

  const RecyclerDetailsScreen({
    super.key,
    required this.recycler,
    this.matchingLot,
  });

  void _showHandoverConfirmation(BuildContext context) {
    final lotProvider = Provider.of<LotProvider>(context, listen: false);
    final recyclerProvider = Provider.of<RecyclerProvider>(
      context,
      listen: false,
    );

    // If no lot was passed directly, use the latest lot from lotProvider or create a fallback
    final targetLot =
        matchingLot ??
        (lotProvider.lots.isNotEmpty
            ? lotProvider.lots.first
            : EwasteLot(
                id: 'KC-2026-DEMO',
                materialKey: 'copper',
                materialName: 'Copper (तांबा)',
                quantity: 5.0,
                unit: 'kg',
                ratePerUnit: 720.0,
                estimatedValue: 3600.0,
                photos: const ['assets/samples/copper_wire.jpg'],
                condition: 'good',
                createdAt: DateTime.now(),
              ));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RequestHandoverModal(
        lot: targetLot,
        recycler: recycler,
        onConfirm: (notes) async {
          // 1. Submit handover request in RecyclerProvider
          final request = await recyclerProvider.submitHandoverRequest(
            lot: targetLot,
            recycler: recycler,
            notes: notes,
          );

          // 2. Assign recycler and update Lot status
          if (recyclerProvider.isOffline) {
            lotProvider.assignRecyclerToLot(
              targetLot.id,
              recyclerId: recycler.id,
              recyclerName: recycler.name,
              newStatus: 'Pending Sync',
            );
          } else {
            lotProvider.assignRecyclerToLot(
              targetLot.id,
              recyclerId: recycler.id,
              recyclerName: recycler.name,
              newStatus: 'Recycler Selected',
            );
            lotProvider.updateLotStatus(targetLot.id, 'Recycler Reviewing');
          }

          if (context.mounted) {
            Navigator.pop(ctx); // Close modal
            // Navigate to Request Submitted success screen
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.requestSubmitted,
              arguments: request,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final langProvider = LanguageProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('recyclerDetails')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Facility Header Card
                  AppCard(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F3020)
                                    : const Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: activeGreen,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: activeGreen,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recycler.name,
                                    style: AppTypography.titleLarge(isDark)
                                        .copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF332005)
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(
                                        AppDimens.radiusSm,
                                      ),
                                    ),
                                    child: Text(
                                      recycler.statusTag,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.md),
                        const Divider(height: 1, thickness: 0.6),
                        const SizedBox(height: AppDimens.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.near_me_rounded,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${recycler.distanceKm} km away (Demo)',
                                  style: AppTypography.bodySmall(isDark),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: recycler.pickupAvailable
                                    ? (isDark
                                          ? AppColors.badgeGreenBgDark
                                          : AppColors.badgeGreenBgLight)
                                    : (isDark
                                          ? const Color(0xFF261D15)
                                          : const Color(0xFFFFFBEB)),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusSm,
                                ),
                              ),
                              child: Text(
                                recycler.pickupAvailable
                                    ? 'Pickup Available'
                                    : 'Drop-off Only',
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Match Explanation Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF132A1C)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(
                        color: activeGreen.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: activeGreen,
                          size: 22,
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'लॉट से सटीक मिलान (Matching Recycler)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFF166534),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                recycler.matchReasonFor(matchingLot),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFFD1FAE5)
                                      : const Color(0xFF14532D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Accepted Materials Section
                  AppCard(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          langProvider.tr('acceptedMaterialsTitle'),
                          style: AppTypography.titleMedium(isDark)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Wrap(
                          spacing: AppDimens.sm,
                          runSpacing: AppDimens.xs,
                          children: recycler.acceptedMaterials.map((mat) {
                            return Chip(
                              label: Text(
                                mat[0].toUpperCase() + mat.substring(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Operating Details Card
                  AppCard(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          Icons.access_time_rounded,
                          langProvider.tr('operatingHours'),
                          recycler.operatingHours,
                          isDark,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                        _buildDetailRow(
                          Icons.location_on_outlined,
                          langProvider.tr('address'),
                          recycler.address,
                          isDark,
                        ),
                        const Divider(height: 16, thickness: 0.5),
                        _buildDetailRow(
                          Icons.phone_outlined,
                          langProvider.tr('contact'),
                          recycler.phone,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Transparent Demo Notice Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(
                        color: isDark
                            ? AppColors.surfaceBorderDark
                            : AppColors.surfaceBorderLight,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Text(
                            recycler.disclaimer,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Primary CTA: Request Handover
                  PrimaryButton(
                    key: const Key('request_handover_cta_button'),
                    title: langProvider.tr('requestHandover'),
                    icon: const Icon(
                      Icons.handshake_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => _showHandoverConfirmation(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
