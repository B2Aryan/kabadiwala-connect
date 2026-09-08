import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  String _formatDateTime(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final mutedColor = isDark ? AppTheme.textMutedDark : AppTheme.textMuted;
    final borderColor = isDark ? AppTheme.cardDarkBorder : AppTheme.borderGrey;

    final dateFormatted = _formatDateTime(transaction.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.tr('transactionDetail'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppTheme.primaryGreen,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    transaction.id,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormatted,
                    style: TextStyle(fontSize: 13, color: mutedColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppTheme.primaryGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lang.tr('statusCompleted'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (transaction.isPendingSync) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                lang.tr('pendingSync'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Item & Material Details
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang.tr('materialDetails'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    lang.tr('lotReference'),
                    transaction.lotId,
                    textColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    lang.tr('whatAreYouSelling'),
                    transaction.materialName,
                    textColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    lang.tr('quantity'),
                    '${transaction.quantity.toStringAsFixed(1)} ${transaction.unit}',
                    textColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    lang.tr('facilityName'),
                    transaction.recyclerName,
                    textColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    lang.tr('paymentMode'),
                    lang.tr('simulatedDirectHandover'),
                    textColor,
                    mutedColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Financial Breakdown (Transparent Math)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calculate_outlined,
                        size: 20,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang.tr('priceCalculation'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    lang.tr('ratePerUnit'),
                    '₹${transaction.ratePerUnit.toStringAsFixed(0)}/${transaction.unit}',
                    textColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    lang.tr('grossAmount'),
                    '₹${transaction.grossAmount.toStringAsFixed(0)}',
                    textColor,
                    mutedColor,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    lang.tr('facilitationFee'),
                    '₹${transaction.facilitationFee.toStringAsFixed(0)}',
                    textColor,
                    mutedColor,
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang.tr('netAmount'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '₹${transaction.netAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.withValues(alpha: 0.08)
                    : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade300.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: Colors.amber,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lang.tr('receiptDisclaimer'),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark
                            ? Colors.amber.shade200
                            : Colors.brown.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Back Button
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(lang.tr('allTransactions')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color textColor,
    Color mutedColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: mutedColor)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
