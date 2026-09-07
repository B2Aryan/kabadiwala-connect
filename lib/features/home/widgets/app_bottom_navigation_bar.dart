import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/localization/language_provider.dart';

/// Reusable AppBottomNavigationBar component for primary app navigation
class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);

    final navItems = [
      _NavItem(
        Icons.home_rounded,
        Icons.home_outlined,
        langProvider.tr('navHome'),
      ),
      _NavItem(
        Icons.inventory_2_rounded,
        Icons.inventory_2_outlined,
        langProvider.tr('navLots'),
      ),
      _NavItem(
        Icons.account_balance_wallet_rounded,
        Icons.account_balance_wallet_outlined,
        langProvider.tr('navEarnings'),
      ),
      _NavItem(
        Icons.person_rounded,
        Icons.person_outline_rounded,
        langProvider.tr('navProfile'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.surfaceBorderDark
                : AppColors.surfaceBorderLight,
            width: AppDimens.borderWidthStandard,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final isSelected = index == selectedIndex;
              final item = navItems[index];
              final activeColor = isDark
                  ? AppColors.primaryGreenDark
                  : AppColors.primaryGreenLight;
              final inactiveColor = isDark
                  ? const Color(0xFF64748B)
                  : const Color(0xFF94A3B8);

              return InkWell(
                onTap: () => onTabSelected(index),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.inactiveIcon,
                        color: isSelected ? activeColor : inactiveColor,
                        size: 26,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  _NavItem(this.activeIcon, this.inactiveIcon, this.label);
}
