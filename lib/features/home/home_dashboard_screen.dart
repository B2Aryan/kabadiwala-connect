import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../data/repositories/mock_repository.dart';
import '../earnings/earnings_screen.dart';
import '../lots/lots_screen.dart';
import '../profile/profile_screen.dart';
import '../recyclers/models/recycler.dart';
import 'widgets/app_bottom_navigation_bar.dart';
import 'widgets/app_header.dart';
import 'widgets/eco_motivation_banner.dart';
import 'widgets/hero_create_lot_button.dart';
import 'widgets/price_board_card.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/recommended_recycler_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentTabIndex = 0;

  void _showNotificationsSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '2 New notifications: Copper rates updated (+2.3%)',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),
    );
  }

  void _navigateToCreateLot() {
    Navigator.of(context).pushNamed(AppRoutes.createLot);
  }

  void _navigateToRecyclers() {
    Navigator.of(context).pushNamed(AppRoutes.recyclers);
  }

  void _navigateToRecyclerDetails(Recycler recycler) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.recyclerDetails, arguments: {'recycler': recycler});
  }

  void _navigateToLots() {
    Navigator.of(context).pushNamed(AppRoutes.lots);
  }

  void _navigateToEarnings() {
    Navigator.of(context).pushNamed(AppRoutes.earnings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Active Tab View Content
            Expanded(
              child: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildHomeFeed(),
                  const LotsScreen(isTab: true),
                  const EarningsScreen(isTab: true),
                  const ProfileScreen(isTab: true),
                ],
              ),
            ),

            // Responsive Bottom Navigation Bar
            AppBottomNavigationBar(
              selectedIndex: _currentTabIndex,
              onTabSelected: (index) {
                setState(() => _currentTabIndex = index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeFeed() {
    final langProvider = Provider.of<LanguageProvider>(context);
    final prices = MockRepository.todayPrices;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          children: [
            // 1. Top Header Bar
            AppHeader(onNotificationTap: _showNotificationsSheet),

            // 2. Scrollable Dashboard Feed
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimens.sm),

                    // Today's Rates Card
                    PriceBoardCard(
                      prices: prices,
                      onSeeAll: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${langProvider.tr("todaysPrices")} - All 12 e-waste categories',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Primary CTA (Create New Lot / Sell E-Waste)
                    HeroCreateLotButton(onPressed: _navigateToCreateLot),
                    const SizedBox(height: AppDimens.lg),

                    // Quick Actions Grid (Nearby Recyclers, My Lots, My Earnings)
                    QuickActionGrid(
                      onNearbyRecyclersTap: _navigateToRecyclers,
                      onMyLotsTap: _navigateToLots,
                      onMyEarningsTap: _navigateToEarnings,
                    ),
                    const SizedBox(height: AppDimens.md),

                    // Top Recommended Authorized Recycler Card
                    RecommendedRecyclerCard(
                      onSelect: _navigateToRecyclerDetails,
                    ),
                    const SizedBox(height: AppDimens.lg),

                    // Impact Motivation Card
                    const EcoMotivationBanner(),
                    const SizedBox(height: AppDimens.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
