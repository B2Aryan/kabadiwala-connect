import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/models/material_price_model.dart';
import '../../../shared/widgets/app_card.dart';
import 'rate_row.dart';

class PriceBoardCard extends StatelessWidget {
  final List<MaterialPriceModel> prices;
  final VoidCallback? onSeeAll;

  const PriceBoardCard({super.key, required this.prices, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.lg,
        vertical: AppDimens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langProvider.tr('todaysPrices'),
                style: AppTypography.titleMedium(isDark)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    langProvider.tr('seeAll'),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.primaryGreenDark
                          : AppColors.primaryGreenLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: AppDimens.sm),

          // Price Rows using RateRow component
          ...prices.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == prices.length - 1;

            return RateRow(item: item, isLast: isLast);
          }),
        ],
      ),
    );
  }
}
