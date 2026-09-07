import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/handover_request.dart';

class RequestSubmittedScreen extends StatelessWidget {
  final HandoverRequest request;

  const RequestSubmittedScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final langProvider = LanguageProvider.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimens.xl),

                  // Success Emblem
                  Container(
                    width: 90,
                    height: 90,
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
                      size: 52,
                      color: activeGreen,
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),

                  // Title
                  Text(
                    langProvider.tr('requestSubmittedTitle'),
                    style: AppTypography.headlineMedium(isDark)
                        .copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    langProvider.tr('requestSubmittedSub'),
                    style: AppTypography.bodyMedium(isDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Details Card
                  AppCard(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Column(
                      children: [
                        // Request ID Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF162A1F)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusPill,
                            ),
                            border: Border.all(
                              color: activeGreen.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            request.id,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: activeGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.md),
                        const Divider(height: 1, thickness: 0.6),
                        const SizedBox(height: AppDimens.md),

                        _buildRow('लॉट आईडी (Lot ID)', request.lotId, isDark),
                        const SizedBox(height: AppDimens.sm),
                        _buildRow(
                          'रीसायकलकर्ता (Recycler)',
                          request.recyclerName,
                          isDark,
                        ),
                        const SizedBox(height: AppDimens.sm),
                        _buildRow(
                          'स्थिति (Status)',
                          langProvider.tr('statusPending'),
                          isDark,
                          isStatus: true,
                        ),
                        const SizedBox(height: AppDimens.sm),
                        _buildRow(
                          'अनुमानित मूल्य (Value)',
                          '₹${request.estimatedValue.toInt()}',
                          isDark,
                          isHighlight: true,
                          highlightColor: activeGreen,
                        ),
                        const SizedBox(height: AppDimens.sm),
                        _buildRow(
                          'समय (Timestamp)',
                          '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year} • ${request.createdAt.hour}:${request.createdAt.minute.toString().padLeft(2, '0')}',
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xl),

                  // Primary CTA: Track Handover
                  PrimaryButton(
                    key: const Key('track_handover_button'),
                    title: langProvider.tr('trackHandover'),
                    icon: const Icon(
                      Icons.timeline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.handoverTracking,
                        arguments: request,
                      );
                    },
                  ),
                  const SizedBox(height: AppDimens.md),

                  // Secondary CTA: Back to My Lots
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
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusLg,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.lots);
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
                  const SizedBox(height: AppDimens.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    bool isDark, {
    bool isHighlight = false,
    bool isStatus = false,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTypography.bodySmall(isDark))),
        const SizedBox(width: AppDimens.xs),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF261D15) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 13,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight
                  ? highlightColor
                  : (isDark
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF0F172A)),
            ),
          ),
      ],
    );
  }
}
