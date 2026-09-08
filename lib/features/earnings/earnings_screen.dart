import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import 'models/transaction_model.dart';
import 'services/transaction_provider.dart';

class EarningsScreen extends StatefulWidget {
  final bool isTab;
  const EarningsScreen({super.key, this.isTab = false});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _filter = 'all'; // 'all', 'completed', 'pending'

  String _formatShortDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final txnProvider = context.watch<TransactionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final mutedColor = isDark ? AppTheme.textMutedDark : AppTheme.textMuted;
    final borderColor = isDark ? AppTheme.cardDarkBorder : AppTheme.borderGrey;

    final allTxns = txnProvider.transactions;
    final filteredTxns = allTxns.where((t) {
      if (_filter == 'completed') {
        return t.status == TransactionStatus.completed;
      }
      if (_filter == 'pending') {
        return t.isPendingSync || t.status == TransactionStatus.pending;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.tr('ledgerTitle'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          if (txnProvider.pendingSyncCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  final synced = txnProvider.syncPendingTransactions();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          lang.tr('syncSuccess', params: {'count': '$synced'}),
                        ),
                        backgroundColor: AppTheme.primaryGreen,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.sync_rounded,
                  size: 18,
                  color: Colors.amber,
                ),
                label: Text(
                  lang.tr('syncNow'),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Card: Total Recorded Value
              AppCard(
                backgroundColor: isDark
                    ? const Color(0xFF10281C)
                    : const Color(0xFFE8F5E9),
                borderColor: isDark
                    ? AppColors.primaryGreenDark
                    : AppColors.primaryGreenLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            lang.tr('totalEarnings'),
                            style: AppTypography.bodyMedium(isDark),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: AppTheme.primaryGreen,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Circular Ledger',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${txnProvider.totalEarnings.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.primaryGreenDark
                            : AppColors.primaryGreenLight,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      '${txnProvider.completedLotsCount} ${lang.tr('completedLots').toLowerCase()}',
                      style: TextStyle(fontSize: 13, color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.md),

              // Metrics Row: This Month & Pending
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.tr('thisMonthEarnings'),
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${txnProvider.thisMonthEarnings.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.tr('pendingReceipts'),
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${txnProvider.pendingEarnings.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: txnProvider.pendingEarnings > 0
                                  ? Colors.amber.shade700
                                  : textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', lang.tr('allTransactions'), isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'completed',
                      lang.tr('statusCompleted'),
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('pending', lang.tr('pendingSync'), isDark),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              // Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.tr('recentTransactions'),
                    style: AppTypography.titleMedium(isDark)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${filteredTxns.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),

              // Transaction List
              if (filteredTxns.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 44,
                        color: mutedColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lang.tr('noTransactions'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mutedColor, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...filteredTxns.map(
                  (txn) => _buildTransactionCard(txn, context, lang, isDark),
                ),

              const SizedBox(height: AppDimens.xl),

              // Transparent Prototype Disclaimer
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.amber.withValues(alpha: 0.06)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.shade200.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lang.tr('receiptDisclaimer'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.amber.shade200
                              : Colors.brown.shade800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() => _filter = key);
        }
      },
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? AppTheme.primaryGreen
            : (isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }

  Widget _buildTransactionCard(
    Transaction txn,
    BuildContext context,
    LanguageProvider lang,
    bool isDark,
  ) {
    final dateStr = _formatShortDateTime(txn.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.transactionDetail,
            arguments: txn,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F3020)
                      : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_rounded,
                  color: AppTheme.primaryGreen,
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
                        Flexible(
                          child: Text(
                            txn.recyclerName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFFF1F5F9)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (txn.isPendingSync) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Offline',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${txn.materialName} • ${txn.quantity.toStringAsFixed(1)} ${txn.unit} (${txn.lotId})',
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
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+ ₹${txn.netAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark
                          ? AppColors.primaryGreenDark
                          : AppColors.primaryGreenLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
