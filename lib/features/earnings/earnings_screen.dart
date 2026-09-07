import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/app_card.dart';

class EarningsScreen extends StatelessWidget {
  final bool isTab;
  const EarningsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('मेरी कमाई (Earnings)'),
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Hero Card
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
                    Text(
                      'Total Earned (Verified)',
                      style: AppTypography.bodyMedium(isDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹14,250',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.primaryGreenDark
                            : AppColors.primaryGreenLight,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    const Text(
                      '18 completed formal recycling lots',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              Text(
                'Recent Transactions',
                style: AppTypography.titleMedium(isDark)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimens.md),

              _buildTransactionItem(
                'GreenTech Recyclers',
                'Mixed PCB Lot',
                '₹1,250',
                'Today',
                isDark,
              ),
              const SizedBox(height: AppDimens.sm),
              _buildTransactionItem(
                'EcoBharat Clean Facility',
                'Copper Motor Lot',
                '₹2,840',
                'Sep 5',
                isDark,
              ),
              const SizedBox(height: AppDimens.sm),
              _buildTransactionItem(
                'Pune Circular Hub',
                'Aluminium Heat Sinks',
                '₹900',
                'Sep 2',
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String recycler,
    String desc,
    String amount,
    String date,
    bool isDark,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F3020) : const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.call_received_rounded,
              color: isDark
                  ? AppColors.primaryGreenDark
                  : AppColors.primaryGreenLight,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recycler,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  desc,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark
                      ? AppColors.primaryGreenDark
                      : AppColors.primaryGreenLight,
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
