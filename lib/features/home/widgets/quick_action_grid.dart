import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/localization/language_provider.dart';
import 'quick_action_card.dart';

class QuickActionGrid extends StatelessWidget {
  final VoidCallback? onNearbyRecyclersTap;
  final VoidCallback? onMyLotsTap;
  final VoidCallback? onMyEarningsTap;

  const QuickActionGrid({
    super.key,
    this.onNearbyRecyclersTap,
    this.onMyLotsTap,
    this.onMyEarningsTap,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Row(
      children: [
        // 1. Nearby Recyclers
        Expanded(
          child: QuickActionCard(
            icon: Icons.alt_route_rounded,
            title: langProvider.tr('nearbyRecyclers'),
            onTap: onNearbyRecyclersTap,
          ),
        ),
        const SizedBox(width: AppDimens.sm),

        // 2. My Lots
        Expanded(
          child: QuickActionCard(
            icon: Icons.inventory_2_outlined,
            title: langProvider.tr('myLots'),
            onTap: onMyLotsTap,
          ),
        ),
        const SizedBox(width: AppDimens.sm),

        // 3. My Earnings
        Expanded(
          child: QuickActionCard(
            icon: Icons.currency_rupee_rounded,
            title: langProvider.tr('myEarnings'),
            onTap: onMyEarningsTap,
          ),
        ),
      ],
    );
  }
}
