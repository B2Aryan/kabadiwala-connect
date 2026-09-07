import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../lots/models/ewaste_lot.dart';
import '../models/recycler.dart';

/// Modal dialog confirming collector's intent to request handover with a demo recycler.
class RequestHandoverModal extends StatefulWidget {
  final EwasteLot lot;
  final Recycler recycler;
  final Future<void> Function(String? notes) onConfirm;

  const RequestHandoverModal({
    super.key,
    required this.lot,
    required this.recycler,
    required this.onConfirm,
  });

  @override
  State<RequestHandoverModal> createState() => _RequestHandoverModalState();
}

class _RequestHandoverModalState extends State<RequestHandoverModal> {
  bool _isSending = false;

  Future<void> _handleSend() async {
    setState(() => _isSending = true);
    await widget.onConfirm(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final langProvider = LanguageProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppDimens.lg,
        right: AppDimens.lg,
        top: AppDimens.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              // Title
              Text(
                langProvider.tr('handoverConfirmTitle'),
                style: AppTypography.titleLarge(isDark)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                langProvider.tr('handoverConfirmNotice'),
                style: AppTypography.bodySmall(isDark),
              ),
              const SizedBox(height: AppDimens.lg),

              // Lot Details Summary Card
              AppCard(
                padding: const EdgeInsets.all(AppDimens.md),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.lot.id,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: activeGreen,
                          ),
                        ),
                        Text(
                          '₹${widget.lot.estimatedValue.toInt()}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: activeGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xs),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: AppDimens.xs),
                    _buildRow(
                      'सामग्री (Material)',
                      widget.lot.materialName,
                      isDark,
                    ),
                    const SizedBox(height: 4),
                    _buildRow(
                      'मात्रा (Quantity)',
                      '${widget.lot.quantity % 1 == 0 ? widget.lot.quantity.toInt() : widget.lot.quantity} ${widget.lot.unit}',
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.md),

              // Target Recycler Card
              AppCard(
                padding: const EdgeInsets.all(AppDimens.md),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F3020)
                            : const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.storefront_rounded,
                        color: activeGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recycler.name,
                            style: AppTypography.titleMedium(isDark)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.recycler.distanceKm} km away • ${widget.recycler.pickupAvailable ? 'Pickup Available' : 'Drop-off'}',
                            style: AppTypography.bodySmall(isDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              // Action Buttons
              if (_isSending)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreenLight,
                    ),
                  ),
                )
              else ...[
                PrimaryButton(
                  key: const Key('send_handover_request_button'),
                  title: langProvider.tr('sendRequest'),
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _handleSend,
                ),
                const SizedBox(height: AppDimens.sm),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeightStandard,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      langProvider.tr('cancel'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTypography.bodySmall(isDark))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
