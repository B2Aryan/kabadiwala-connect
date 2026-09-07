import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/language_provider.dart';
import '../../../shared/widgets/primary_button.dart';
import '../services/recycler_provider.dart';

/// Modal bottom sheet allowing collectors to filter recyclers by material, pickup, and distance.
class RecyclerFilterSheet extends StatefulWidget {
  final RecyclerProvider provider;

  const RecyclerFilterSheet({super.key, required this.provider});

  @override
  State<RecyclerFilterSheet> createState() => _RecyclerFilterSheetState();
}

class _RecyclerFilterSheetState extends State<RecyclerFilterSheet> {
  late String _selectedMaterial;
  late bool _pickupOnly;
  late double? _maxDistance;

  @override
  void initState() {
    super.initState();
    _selectedMaterial = widget.provider.selectedMaterialFilter;
    _pickupOnly = widget.provider.pickupOnly;
    _maxDistance = widget.provider.maxDistanceKm;
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
              // Top drag handle
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

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langProvider.tr('filterTitle'),
                    style: AppTypography.titleLarge(isDark)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedMaterial = 'all';
                        _pickupOnly = false;
                        _maxDistance = null;
                      });
                    },
                    child: Text(
                      langProvider.tr('resetFilters'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),

              // Section 1: Material Accepted
              Text(
                langProvider.tr('filterMaterial'),
                style: AppTypography.titleMedium(isDark)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimens.sm),
              Wrap(
                spacing: AppDimens.sm,
                runSpacing: AppDimens.xs,
                children: [
                  _buildChoiceChip(
                    'all',
                    langProvider.tr('allMaterials'),
                    _selectedMaterial == 'all',
                    isDark,
                    activeGreen,
                    () => setState(() => _selectedMaterial = 'all'),
                  ),
                  _buildChoiceChip(
                    'copper',
                    'Copper (तांबा)',
                    _selectedMaterial == 'copper',
                    isDark,
                    activeGreen,
                    () => setState(() => _selectedMaterial = 'copper'),
                  ),
                  _buildChoiceChip(
                    'aluminium',
                    'Aluminium',
                    _selectedMaterial == 'aluminium',
                    isDark,
                    activeGreen,
                    () => setState(() => _selectedMaterial = 'aluminium'),
                  ),
                  _buildChoiceChip(
                    'eWaste',
                    'E-Waste (PCBs)',
                    _selectedMaterial == 'eWaste',
                    isDark,
                    activeGreen,
                    () => setState(() => _selectedMaterial = 'eWaste'),
                  ),
                  _buildChoiceChip(
                    'other',
                    'Other Scrap',
                    _selectedMaterial == 'other',
                    isDark,
                    activeGreen,
                    () => setState(() => _selectedMaterial = 'other'),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),

              // Section 2: Pickup Availability
              Text(
                langProvider.tr('filterPickup'),
                style: AppTypography.titleMedium(isDark)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimens.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceChip(
                      'all_pickup',
                      langProvider.tr('anyDistance'),
                      !_pickupOnly,
                      isDark,
                      activeGreen,
                      () => setState(() => _pickupOnly = false),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: _buildChoiceChip(
                      'pickup_only',
                      langProvider.tr('pickupOnlyOption'),
                      _pickupOnly,
                      isDark,
                      activeGreen,
                      () => setState(() => _pickupOnly = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),

              // Section 3: Distance
              Text(
                langProvider.tr('filterDistance'),
                style: AppTypography.titleMedium(isDark)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimens.sm),
              Wrap(
                spacing: AppDimens.sm,
                runSpacing: AppDimens.xs,
                children: [
                  _buildChoiceChip(
                    'dist_any',
                    langProvider.tr('anyDistance'),
                    _maxDistance == null,
                    isDark,
                    activeGreen,
                    () => setState(() => _maxDistance = null),
                  ),
                  _buildChoiceChip(
                    'dist_3',
                    '< 3 km',
                    _maxDistance == 3.0,
                    isDark,
                    activeGreen,
                    () => setState(() => _maxDistance = 3.0),
                  ),
                  _buildChoiceChip(
                    'dist_5',
                    '< 5 km',
                    _maxDistance == 5.0,
                    isDark,
                    activeGreen,
                    () => setState(() => _maxDistance = 5.0),
                  ),
                  _buildChoiceChip(
                    'dist_10',
                    '< 10 km',
                    _maxDistance == 10.0,
                    isDark,
                    activeGreen,
                    () => setState(() => _maxDistance = 10.0),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.xl),

              // Apply Filters Primary CTA
              PrimaryButton(
                title: langProvider.tr('applyFilters'),
                onPressed: () {
                  widget.provider.applyFilters(
                    material: _selectedMaterial,
                    pickupOnly: _pickupOnly,
                    maxDistance: _maxDistance,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String key,
    String label,
    bool isSelected,
    bool isDark,
    Color activeGreen,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF132A1C) : const Color(0xFFDCFCE7))
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected
                ? activeGreen
                : (isDark
                      ? AppColors.surfaceBorderDark
                      : AppColors.surfaceBorderLight),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? activeGreen
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }
}
