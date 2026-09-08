import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../recyclers/models/recycler.dart';
import '../../recyclers/services/recycler_provider.dart';

class RecommendedRecyclerCard extends StatelessWidget {
  final ValueChanged<Recycler> onSelect;

  const RecommendedRecyclerCard({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final langProvider = LanguageProvider.of(context);
    final recyclerProvider = Provider.of<RecyclerProvider>(context);

    if (recyclerProvider.recyclers.isEmpty) {
      return const SizedBox.shrink();
    }

    final topRecycler = recyclerProvider.recyclers.first;

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Badge & "Nearby Demo"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: activeGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        langProvider.tr('recommendedRecycler'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: activeGreen,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF332005)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Text(
                  langProvider.tr('demoNoticeBadge'),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),

          // Recycler Info
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F3020)
                      : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: activeGreen.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: activeGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topRecycler.name,
                      style: AppTypography.titleMedium(
                        isDark,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 14.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${topRecycler.distanceKm} km • ${topRecycler.pickupAvailable ? langProvider.tr('pickupAvailable') : langProvider.tr('dropOffOnly')}',
                      style: AppTypography.bodySmall(isDark),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: activeGreen,
                  side: BorderSide(color: activeGreen, width: 1.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  ),
                ),
                onPressed: () => onSelect(topRecycler),
                child: const Text(
                  'View →',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
