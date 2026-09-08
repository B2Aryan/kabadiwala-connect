import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../lots/models/ewaste_lot.dart';
import '../lots/services/lot_provider.dart';
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

  void _openLotSelector(
    BuildContext context,
    LotProvider lotProvider,
    RecyclerProvider recyclerProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final lang = LanguageProvider.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      builder: (ctx) {
        final availableLots = lotProvider.lots;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.tr('selectLotForHandover'),
                      style: AppTypography.titleMedium(isDark)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),
                if (availableLots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
                    child: Center(
                      child: Text(
                        'No created lots available yet.',
                        style: AppTypography.bodyMedium(isDark),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: availableLots.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimens.sm),
                      itemBuilder: (c, idx) {
                        final lot = availableLots[idx];
                        final isSelected = _activeLot?.id == lot.id;
                        return InkWell(
                          onTap: () {
                            setState(() => _activeLot = lot);
                            recyclerProvider.setMatchingLot(lot);
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusMd,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppDimens.md),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                        ? const Color(0xFF132A1C)
                                        : const Color(0xFFDCFCE7))
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusMd,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? activeGreen
                                    : (isDark
                                          ? AppColors.surfaceBorderDark
                                          : AppColors.surfaceBorderLight),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 20,
                                  color: isSelected
                                      ? activeGreen
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${lot.id} • ${lot.materialName}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? const Color(0xFFF1F5F9)
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        '${lot.quantity} ${lot.unit} • ₹${lot.estimatedValue.toInt()}',
                                        style: AppTypography.bodySmall(isDark),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: activeGreen,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
    final lotProvider = Provider.of<LotProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.tr('recyclersTitle')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Offline Simulation toggle button
          IconButton(
            tooltip: recyclerProvider.isOffline
                ? 'Offline Mode Active'
                : 'Online Mode',
            icon: Icon(
              recyclerProvider.isOffline
                  ? Icons.cloud_off_rounded
                  : Icons.cloud_done_rounded,
              color: recyclerProvider.isOffline
                  ? const Color(0xFFF59E0B)
                  : activeGreen,
            ),
            onPressed: () {
              recyclerProvider.toggleOffline();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    recyclerProvider.isOffline
                        ? 'Simulating Offline Mode: Requests will enter Pending Sync'
                        : 'Online Mode: Direct sync to demo facility enabled',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
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
                      // Offline Status Notice if active
                      if (recyclerProvider.isOffline) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: AppDimens.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF261D15)
                                : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusSm,
                            ),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                size: 14,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  langProvider.tr('offlineNotice'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

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

                      // Matching Lot Context Banner or "Select a Lot" prompt
                      const SizedBox(height: AppDimens.sm),
                      if (_activeLot != null)
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
                                    InkWell(
                                      onTap: () => _openLotSelector(
                                        context,
                                        lotProvider,
                                        recyclerProvider,
                                      ),
                                      child: Text(
                                        'Change',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: activeGreen,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (lotProvider.lots.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _openLotSelector(
                                  context,
                                  lotProvider,
                                  recyclerProvider,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusSm,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radiusSm,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.surfaceBorderDark
                                          : AppColors.surfaceBorderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.add_link_rounded,
                                        size: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          langProvider.tr(
                                            'selectLotForHandover',
                                          ),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Select →',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: activeGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            final score =
                                index < recyclerProvider.rankedResults.length
                                ? recyclerProvider.rankedResults[index].score
                                : null;
                            return RecyclerCard(
                              key: Key('recycler_card_${rec.id}'),
                              recycler: rec,
                              matchingLot: _activeLot,
                              matchScore: score,
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
