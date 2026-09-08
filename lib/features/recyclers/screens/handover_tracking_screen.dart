import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../earnings/services/transaction_provider.dart';
import '../../lots/models/ewaste_lot.dart';
import '../../lots/services/lot_provider.dart';
import '../models/handover_request.dart';
import '../services/recycler_provider.dart';

class HandoverTrackingScreen extends StatelessWidget {
  final HandoverRequest request;

  const HandoverTrackingScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final langProvider = LanguageProvider.of(context);
    final recyclerProvider = Provider.of<RecyclerProvider>(context);
    final lotProvider = Provider.of<LotProvider>(context, listen: false);
    final txnProvider = Provider.of<TransactionProvider>(context);

    // Get live updated request from provider if available
    final liveRequest =
        recyclerProvider.getRequestForLot(request.lotId) ?? request;
    final isPendingSync = liveRequest.isPendingSync;

    final steps = [
      {
        'title': isPendingSync
            ? 'अनुरोध सिंक प्रतीक्षित (Pending Sync)'
            : langProvider.tr('stepRequestSent'),
        'desc': isPendingSync
            ? 'ऑफ़लाइन सहेजा गया। नेटवर्क बहाल होने पर भेजा जाएगा।'
            : 'लॉट अनुरोध सफलतापूर्वक रीसायकलकर्ता को भेजा गया',
        'isDone': !isPendingSync,
        'isActive': isPendingSync,
      },
      {
        'title': langProvider.tr('stepRecyclerReviewing'),
        'desc': 'रीसायकलकर्ता सामग्री ग्रेड और वजन की समीक्षा कर रहा है',
        'isDone':
            liveRequest.status == HandoverStatus.scheduled ||
            liveRequest.status == HandoverStatus.handoverPending ||
            liveRequest.status == HandoverStatus.confirmed,
        'isActive':
            !isPendingSync &&
            (liveRequest.status == HandoverStatus.requested ||
                liveRequest.status == HandoverStatus.reviewing),
      },
      {
        'title': langProvider.tr('stepPickupScheduled'),
        'desc': 'पिकअप वैन प्रस्थान या डिपो में सामग्री जमा करना',
        'isDone':
            liveRequest.status == HandoverStatus.handoverPending ||
            liveRequest.status == HandoverStatus.confirmed,
        'isActive': liveRequest.status == HandoverStatus.scheduled,
      },
      {
        'title': langProvider.tr('stepHandoverConfirmed'),
        'desc': 'भौतिक वजन सत्यापन, डिजिटल रसीद और भुगतान जारी',
        'isDone': liveRequest.status == HandoverStatus.confirmed,
        'isActive': liveRequest.status == HandoverStatus.handoverPending,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('handoverTrackingTitle')),
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
                  // Pending Sync Action Card (if offline / pending sync)
                  if (isPendingSync) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: AppDimens.md),
                      padding: const EdgeInsets.all(AppDimens.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF261D15)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: Color(0xFFD97706),
                            size: 22,
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ऑफ़लाइन अनुरोध (Offline Pending Sync)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'कनेक्ट होने पर रीसायकलकर्ता को भेजने के लिए सिंक करें।',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0xFFFDE68A)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD97706),
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              recyclerProvider.setOffline(false);
                              final synced = recyclerProvider
                                  .syncPendingRequests(lotProvider);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    langProvider.tr(
                                      'syncSuccess',
                                      params: {'count': '$synced'},
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(langProvider.tr('syncNow')),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Request Summary Header Card
                  AppCard(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              liveRequest.lotId,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: activeGreen,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF261D15)
                                    : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusSm,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                liveRequest.status.localizedLabel(
                                  langProvider.currentLanguage.code,
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          liveRequest.recyclerName,
                          style: AppTypography.titleMedium(isDark)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${liveRequest.quantity} ${liveRequest.unit} • ₹${liveRequest.estimatedValue.toInt()} Estimated',
                          style: AppTypography.bodySmall(isDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Timeline Header
                  Text(
                    'हैंडओवर प्रगति (Lifecycle Timeline)',
                    style: AppTypography.titleMedium(isDark)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppDimens.md),

                  // 4-Step Vertical Timeline
                  AppCard(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Column(
                      children: List.generate(steps.length, (index) {
                        final step = steps[index];
                        final isLast = index == steps.length - 1;
                        final isDone = step['isDone'] as bool;
                        final isActive = step['isActive'] as bool;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step indicator column (icon + line)
                              Column(
                                children: [
                                  _buildTimelineNode(
                                    isDone: isDone,
                                    isActive: isActive,
                                    activeGreen: activeGreen,
                                    isDark: isDark,
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: isDone
                                            ? activeGreen
                                            : (isDark
                                                  ? const Color(0xFF334155)
                                                  : const Color(0xFFE2E8F0)),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: AppDimens.md),

                              // Step Content
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: isLast ? 0 : AppDimens.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step['title'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isActive || isDone
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isDone
                                              ? activeGreen
                                              : (isActive
                                                    ? (isDark
                                                          ? const Color(
                                                              0xFFF1F5F9,
                                                            )
                                                          : const Color(
                                                              0xFF0F172A,
                                                            ))
                                                    : (isDark
                                                          ? const Color(
                                                              0xFF64748B,
                                                            )
                                                          : const Color(
                                                              0xFF94A3B8,
                                                            ))),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        step['desc'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Demo Note Card
                  Container(
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
                            langProvider.tr('trackingDemoNotice'),
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
                  const SizedBox(height: AppDimens.xl),

                  // Navigation Actions
                  if (liveRequest.status == HandoverStatus.confirmed) ...[
                    // Primary: View Digital Receipt
                    SizedBox(
                      width: double.infinity,
                      height: AppDimens.buttonHeightStandard,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusLg,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          var txn = txnProvider.getTransactionByLotId(
                            liveRequest.lotId,
                          );
                          if (txn == null) {
                            final lot = lotProvider.lots
                                .cast<EwasteLot?>()
                                .firstWhere(
                                  (l) => l?.id == liveRequest.lotId,
                                  orElse: () => null,
                                );
                            txn = await txnProvider
                                .recordHandoverCompletionFromRequest(
                                  request: liveRequest,
                                  lot: lot,
                                );
                          }
                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.transactionDetail,
                              arguments: txn,
                            );
                          }
                        },
                        icon: const Icon(Icons.receipt_long_rounded, size: 20),
                        label: Text(
                          langProvider.tr('viewReceipt'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                  ] else if (!isPendingSync) ...[
                    // Simulate Handover Completion (Demo)
                    SizedBox(
                      width: double.infinity,
                      height: AppDimens.buttonHeightStandard,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusLg,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          recyclerProvider.advanceRequestStatus(
                            liveRequest.lotId,
                            HandoverStatus.confirmed,
                            lotProvider,
                          );
                          final lot = lotProvider.lots
                              .cast<EwasteLot?>()
                              .firstWhere(
                                (l) => l?.id == liveRequest.lotId,
                                orElse: () => null,
                              );
                          await txnProvider.recordHandoverCompletionFromRequest(
                            request: liveRequest,
                            lot: lot,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  langProvider.tr('statusHandoverCompleted'),
                                ),
                                backgroundColor: AppTheme.primaryGreen,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.verified_rounded, size: 18),
                        label: Text(
                          langProvider.tr('simulateHandoverComplete'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                  ],

                  // Secondary Action: Back to My Lots
                  SizedBox(
                    width: double.infinity,
                    height: AppDimens.buttonHeightStandard,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white
                            : AppTheme.textDark,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.surfaceBorderDark
                              : AppColors.surfaceBorderLight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusLg,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.lots,
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: Text(
                        langProvider.tr('backToMyLots'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineNode({
    required bool isDone,
    required bool isActive,
    required Color activeGreen,
    required bool isDark,
  }) {
    if (isDone) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: activeGreen, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }

    if (isActive) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF332005) : const Color(0xFFFEF3C7),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFFD97706),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
    );
  }
}
