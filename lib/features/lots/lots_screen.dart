import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../earnings/models/transaction_model.dart';
import '../earnings/services/transaction_provider.dart';
import '../recyclers/services/recycler_provider.dart';
import 'services/lot_provider.dart';

class LotsScreen extends StatelessWidget {
  final bool isTab;
  const LotsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lotProvider = Provider.of<LotProvider>(context);
    final recyclerProvider = Provider.of<RecyclerProvider>(context);
    final txnProvider = Provider.of<TransactionProvider>(context);
    final lots = lotProvider.lots;

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('myLots')),
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: lots.isEmpty
                ? Center(
                    child: Text(
                      'कोई लॉट उपलब्ध नहीं है (No Lots Available)',
                      style: AppTypography.bodyLarge(isDark),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    itemCount: lots.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimens.md),
                    itemBuilder: (context, index) {
                      final lot = lots[index];
                      final request = recyclerProvider.getRequestForLot(lot.id);

                      return InkWell(
                        onTap: () {
                          if (request != null) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.handoverTracking,
                              arguments: request,
                            );
                          } else if (lot.status == 'Created') {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.recyclers,
                              arguments: lot,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        child: AppCard(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Lot ID & Status Badge
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lot.id,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.primaryGreenDark
                                          : AppColors.primaryGreenLight,
                                    ),
                                  ),
                                  _buildStatusBadge(lot.status, isDark),
                                ],
                              ),
                              const SizedBox(height: AppDimens.sm),

                              // Material Name
                              Text(
                                lot.materialName,
                                style: AppTypography.titleMedium(isDark)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),

                              // Quantity & Rate
                              Text(
                                '${lot.quantity % 1 == 0 ? lot.quantity.toInt() : lot.quantity} ${lot.unit} • ₹${lot.ratePerUnit.toInt()}/${lot.unit}',
                                style: AppTypography.bodyMedium(isDark),
                              ),
                              const SizedBox(height: AppDimens.sm),

                              // Value & Time
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimated: ₹${lot.estimatedValue.toInt()}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.primaryGreenDark
                                          : AppColors.primaryGreenLight,
                                    ),
                                  ),
                                  Text(
                                    '${lot.createdAt.hour}:${lot.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),

                              // Action Shortcuts for Created Lot or Tracking
                              if (lot.status == 'Created') ...[
                                const SizedBox(height: AppDimens.sm),
                                const Divider(height: 1, thickness: 0.5),
                                const SizedBox(height: AppDimens.xs),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.recyclers,
                                        arguments: lot,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.alt_route_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Find Recyclers →',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: isDark
                                          ? AppColors.primaryGreenDark
                                          : AppColors.primaryGreenLight,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                              ] else if (lot.status.contains('Verified') ||
                                  lot.status.contains('Confirmed') ||
                                  lot.status.contains('Completed') ||
                                  txnProvider.getTransactionByLotId(lot.id) !=
                                      null) ...[
                                const SizedBox(height: AppDimens.sm),
                                const Divider(height: 1, thickness: 0.5),
                                const SizedBox(height: AppDimens.xs),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 15,
                                          color: AppTheme.primaryGreen,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Handover Verified',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? AppColors.primaryGreenDark
                                                : AppColors.primaryGreenLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: isDark
                                            ? AppColors.primaryGreenDark
                                            : AppColors.primaryGreenLight,
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      onPressed: () {
                                        var txn = txnProvider
                                            .getTransactionByLotId(lot.id);
                                        txn ??= Transaction(
                                          id: 'TXN-${lot.id}',
                                          handoverRequestId: 'REQ-${lot.id}',
                                          lotId: lot.id,
                                          material: lot.materialName,
                                          quantity: lot.quantity,
                                          unit: lot.unit,
                                          agreedRate: lot.ratePerUnit,
                                          grossAmount: lot.estimatedValue,
                                          netAmount: lot.estimatedValue,
                                          recyclerId:
                                              lot.recyclerId ?? 'REC-DEMO-001',
                                          recyclerName:
                                              lot.recyclerName ??
                                              'GreenCycle Recycling — Demo',
                                          createdAt: lot.createdAt,
                                        );
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.transactionDetail,
                                          arguments: txn,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.receipt_long_rounded,
                                        size: 15,
                                      ),
                                      label: const Text(
                                        'View Receipt →',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (request != null) ...[
                                const SizedBox(height: AppDimens.sm),
                                const Divider(height: 1, thickness: 0.5),
                                const SizedBox(height: AppDimens.xs),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Recycler: ${request.recyclerName}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      request.isPendingSync
                                          ? 'Sync / Track →'
                                          : 'Track →',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.primaryGreenDark
                                            : AppColors.primaryGreenLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (lot.recyclerName != null) ...[
                                const SizedBox(height: AppDimens.sm),
                                const Divider(height: 1, thickness: 0.5),
                                const SizedBox(height: AppDimens.xs),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Recycler: ${lot.recyclerName}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'Request Pickup →',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.primaryGreenDark
                                            : AppColors.primaryGreenLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color bg;
    Color text;

    switch (status) {
      case 'Handover Confirmed':
      case 'Verified Handover':
        bg = isDark ? AppColors.badgeGreenBgDark : AppColors.badgeGreenBgLight;
        text = isDark
            ? AppColors.badgeGreenTextDark
            : AppColors.badgeGreenTextLight;
        break;
      case 'Recycler Reviewing':
        bg = isDark ? const Color(0xFF2E1C38) : const Color(0xFFF3E8FF);
        text = isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7E22CE);
        break;
      case 'Handover Requested':
      case 'Pickup Requested':
        bg = isDark ? const Color(0xFF132338) : const Color(0xFFE0F2FE);
        text = isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1);
        break;
      case 'Pickup Scheduled':
        bg = isDark ? const Color(0xFF112D29) : const Color(0xFFCCFBF1);
        text = isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E);
        break;
      case 'Handover Pending':
        bg = isDark ? const Color(0xFF2E1A1A) : const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        break;
      case 'Pending Sync':
        bg = isDark ? const Color(0xFF261D15) : const Color(0xFFFFFBEB);
        text = const Color(0xFFD97706);
        break;
      case 'Recycler Selected':
        bg = isDark ? const Color(0xFF132A1C) : const Color(0xFFDCFCE7);
        text = isDark
            ? AppColors.primaryGreenDark
            : AppColors.primaryGreenLight;
        break;
      case 'Created':
      default:
        bg = isDark ? const Color(0xFF2A2007) : const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
