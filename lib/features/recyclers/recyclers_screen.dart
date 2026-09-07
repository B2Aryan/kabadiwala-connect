import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../lots/models/ewaste_lot.dart';
import 'models/recycler.dart';
import 'services/recycler_provider.dart';
import 'widgets/recycler_card.dart';
import 'widgets/recycler_filter_sheet.dart';

class RecyclersScreen extends StatefulWidget {
  final EwasteLot? matchingLot;

  const RecyclersScreen({super.key, this.matchingLot});

  @override
  State<RecyclersScreen> createState() => _RecyclersScreenState();
}

class _RecyclersScreenState extends State<RecyclersScreen> {
  final TextEditingController _searchController = TextEditingController();
  EwasteLot? _activeLot;

  @override
  void initState() {
    super.initState();
    _activeLot = widget.matchingLot;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RecyclerProvider>(context, listen: false);
      // Check route arguments if not passed in widget constructor
      final routeArg = ModalRoute.of(context)?.settings.arguments as EwasteLot?;
      if (routeArg != null) {
        setState(() => _activeLot = routeArg);
      }
      provider.setMatchingLot(_activeLot);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(RecyclerProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RecyclerFilterSheet(provider: provider),
    );
  }

  void _navigateToDetails(Recycler recycler) {
    Navigator.pushNamed(
      context,
      AppRoutes.recyclerDetails,
      arguments: {'recycler': recycler, 'matchingLot': _activeLot},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final langProvider = LanguageProvider.of(context);
    final recyclerProvider = Provider.of<RecyclerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('recyclersTitle')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Top Header Card with Guidance & Search
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.lg,
                    AppDimens.sm,
                    AppDimens.lg,
                    AppDimens.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Friendly Guidance Row & Mock GPS indicator
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              langProvider.tr('recyclersSub'),
                              style: AppTypography.bodySmall(isDark),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF132A1C)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusSm,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 12,
                                  color: activeGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Pune MIDC (Demo)',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: activeGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),

                      // Search Bar + Filter Button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusMd,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.surfaceBorderDark
                                      : AppColors.surfaceBorderLight,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) =>
                                    recyclerProvider.setSearchQuery(val),
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFF0F172A),
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: langProvider.tr(
                                    'searchRecyclersHint',
                                  ),
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),

                          // Filter Button with Badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton.filledTonal(
                                key: const Key('recycler_filter_button'),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      recyclerProvider.activeFilterCount > 0
                                      ? (isDark
                                            ? const Color(0xFF132A1C)
                                            : const Color(0xFFDCFCE7))
                                      : (isDark
                                            ? AppColors.surfaceDark
                                            : AppColors.surfaceLight),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radiusMd,
                                    ),
                                    side: BorderSide(
                                      color:
                                          recyclerProvider.activeFilterCount > 0
                                          ? activeGreen
                                          : (isDark
                                                ? AppColors.surfaceBorderDark
                                                : AppColors.surfaceBorderLight),
                                    ),
                                  ),
                                ),
                                onPressed: () =>
                                    _openFilterSheet(recyclerProvider),
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color: recyclerProvider.activeFilterCount > 0
                                      ? activeGreen
                                      : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B)),
                                  size: 20,
                                ),
                              ),
                              if (recyclerProvider.activeFilterCount > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: activeGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${recyclerProvider.activeFilterCount}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      // Matching Lot Badge if lot context present
                      if (_activeLot != null) ...[
                        const SizedBox(height: AppDimens.sm),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF162A1F)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusSm,
                                  ),
                                  border: Border.all(
                                    color: activeGreen.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 14,
                                      color: activeGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        langProvider.tr(
                                          'matchingLotBanner',
                                          params: {
                                            'lotId': _activeLot!.id,
                                            'material':
                                                _activeLot!.materialName,
                                          },
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: activeGreen,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Recycler Cards List
                Expanded(
                  child: recyclerProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreenLight,
                          ),
                        )
                      : recyclerProvider.recyclers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimens.lg),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: AppDimens.md),
                                Text(
                                  langProvider.tr('noRecyclersFound'),
                                  style: AppTypography.bodyMedium(isDark),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppDimens.md),
                                ElevatedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    recyclerProvider.resetFilters();
                                  },
                                  child: Text(langProvider.tr('resetFilters')),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          itemCount: recyclerProvider.recyclers.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppDimens.md),
                          itemBuilder: (context, index) {
                            final rec = recyclerProvider.recyclers[index];
                            return RecyclerCard(
                              key: Key('recycler_card_${rec.id}'),
                              recycler: rec,
                              matchingLot: _activeLot,
                              onTap: () => _navigateToDetails(rec),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
