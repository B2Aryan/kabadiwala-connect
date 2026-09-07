import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/language_provider.dart';
import '../../core/navigation/app_router.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import 'models/ewaste_lot.dart';
import 'services/lot_provider.dart';
import 'services/photo_service.dart';
import 'widgets/lot_progress_indicator.dart';
import 'widgets/lot_review_card.dart';
import 'widgets/lot_step_header.dart';
import 'widgets/material_option_card.dart';
import 'widgets/photo_picker_card.dart';
import 'widgets/quantity_input.dart';
import 'widgets/success_state.dart';
import 'widgets/value_summary_card.dart';

class CreateLotScreen extends StatefulWidget {
  const CreateLotScreen({super.key});

  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  final PageController _pageController = PageController();
  final PhotoService _photoService = MockPhotoService();
  final TextEditingController _notesController = TextEditingController();

  int _currentStep = 1;
  bool _isSubmitting = false;
  EwasteLot? _createdLot;

  @override
  void initState() {
    super.initState();
    // Default draft with at least one sample photo for rapid testing if desired
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lotProvider = Provider.of<LotProvider>(context, listen: false);
      if (lotProvider.draftPhotos.isEmpty) {
        lotProvider.addPhoto('assets/samples/pcb_board.jpg');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleCameraPick(LotProvider lotProvider) async {
    final photo = await _photoService.takePhoto();
    if (photo != null) {
      lotProvider.addPhoto(photo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('फ़ोटो सफलतापूर्वक जोड़ी गई (Camera Photo Added)'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleGalleryPick(LotProvider lotProvider) async {
    final photo = await _photoService.pickFromGallery();
    if (photo != null) {
      lotProvider.addPhoto(photo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('फ़ोटो जोड़ी गई (Gallery Photo Added)'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _submitLot(LotProvider lotProvider) async {
    setState(() => _isSubmitting = true);
    lotProvider.setNotes(_notesController.text.trim());

    final created = await lotProvider.createLot();

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _createdLot = created;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lotProvider = Provider.of<LotProvider>(context);

    // If lot created successfully, show full Success State
    if (_createdLot != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SuccessState(
                lot: _createdLot!,
                onFindRecyclers: () {
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.recyclers,
                    arguments: _createdLot,
                  );
                },
                onViewLots: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.lots);
                },
              ),
            ),
          ),
        ),
      );
    }

    final stepTitles = [
      langProvider.tr('addPhotos'),
      langProvider.tr('materialDetails'),
      langProvider.tr('estimatedValue'),
      langProvider.tr('reviewLot'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // 1. Step Header
                LotStepHeader(
                  title: stepTitles[_currentStep - 1],
                  currentStep: _currentStep,
                  totalSteps: 4,
                  onBack: _prevStep,
                ),

                // 2. Step Progress Bar
                LotProgressIndicator(currentStep: _currentStep, totalSteps: 4),
                const SizedBox(height: AppDimens.sm),

                // 3. PageView with 4 Steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // step buttons control navigation
                    children: [
                      _buildStep1Photos(isDark, langProvider, lotProvider),
                      _buildStep2Materials(isDark, langProvider, lotProvider),
                      _buildStep3Estimate(isDark, langProvider, lotProvider),
                      _buildStep4Review(isDark, langProvider, lotProvider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== STEP 1: ADD PHOTOS ====================
  Widget _buildStep1Photos(
    bool isDark,
    LanguageProvider langProvider,
    LotProvider lotProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoPickerCard(
            photos: lotProvider.draftPhotos,
            onCameraTap: () => _handleCameraPick(lotProvider),
            onGalleryTap: () => _handleGalleryPick(lotProvider),
            onRemovePhoto: (index) => lotProvider.removePhoto(index),
          ),
          const SizedBox(height: AppDimens.lg),

          // Quick samples suggestion
          Text(
            'त्वरित नमूने (Quick E-Waste Presets)',
            style: AppTypography.titleMedium(isDark)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.sm),

          Row(
            children: [
              _buildPresetChip(
                'PCBs',
                'assets/samples/pcb_board.jpg',
                lotProvider,
                isDark,
              ),
              const SizedBox(width: AppDimens.sm),
              _buildPresetChip(
                'Copper Wire',
                'assets/samples/copper_wire.jpg',
                lotProvider,
                isDark,
              ),
              const SizedBox(width: AppDimens.sm),
              _buildPresetChip(
                'Mobiles',
                'assets/samples/mobile_parts.jpg',
                lotProvider,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.xxl),

          // Continue Button
          PrimaryButton(
            key: const Key('step1_continue_button'),
            title: langProvider.tr('continueAction'),
            onPressed: () {
              if (lotProvider.draftPhotos.isEmpty) {
                // Auto add sample if user proceeds
                lotProvider.addPhoto('assets/samples/pcb_board.jpg');
              }
              _nextStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    String label,
    String path,
    LotProvider lotProvider,
    bool isDark,
  ) {
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return Expanded(
      child: InkWell(
        onTap: () => lotProvider.addPhoto(path),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isDark
                  ? AppColors.surfaceBorderDark
                  : AppColors.surfaceBorderLight,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_rounded,
                color: activeGreen,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== STEP 2: MATERIAL DETAILS ====================
  Widget _buildStep2Materials(
    bool isDark,
    LanguageProvider langProvider,
    LotProvider lotProvider,
  ) {
    final materials = [
      {
        'key': 'copper',
        'title': 'Copper (तांबा)',
        'rate': '₹720/kg demo rate',
        'icon': Icons.cable_rounded,
      },
      {
        'key': 'aluminium',
        'title': 'Aluminium (एल्युमिनियम)',
        'rate': '₹180/kg demo rate',
        'icon': Icons.memory_rounded,
      },
      {
        'key': 'eWaste',
        'title': 'E-Waste (इलेक्ट्रॉनिक्स PCBs)',
        'rate': '₹35/kg demo rate',
        'icon': Icons.developer_board_rounded,
      },
      {
        'key': 'other',
        'title': 'Other Scrap (अन्य कचरा)',
        'rate': '₹25/kg demo rate',
        'icon': Icons.devices_other_rounded,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            langProvider.tr('whatAreYouSelling'),
            style: AppTypography.titleLarge(isDark)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.md),

          // Selectable material options
          ...materials.map((mat) {
            final key = mat['key'] as String;
            final isSelected = lotProvider.draftMaterialKey == key;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.sm),
              child: MaterialOptionCard(
                title: mat['title'] as String,
                rateText: mat['rate'] as String,
                icon: mat['icon'] as IconData,
                isSelected: isSelected,
                onTap: () => lotProvider.setMaterial(key),
              ),
            );
          }),
          const SizedBox(height: AppDimens.md),

          // Condition Selector
          Text(
            langProvider.tr('condition'),
            style: AppTypography.titleMedium(isDark)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.sm),

          Row(
            children: [
              _buildConditionChip(
                'good',
                langProvider.tr('conditionGood'),
                lotProvider,
                isDark,
              ),
              const SizedBox(width: AppDimens.sm),
              _buildConditionChip(
                'broken',
                langProvider.tr('conditionBroken'),
                lotProvider,
                isDark,
              ),
              const SizedBox(width: AppDimens.sm),
              _buildConditionChip(
                'scrap',
                langProvider.tr('conditionScrap'),
                lotProvider,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),

          // Quantity Input
          QuantityInput(
            value: lotProvider.draftQuantity,
            unit: lotProvider.draftUnit,
            onChanged: (val) => lotProvider.setQuantity(val),
            onUnitChanged: (unit) => lotProvider.setUnit(unit),
          ),
          const SizedBox(height: AppDimens.xxl),

          // Continue Button
          PrimaryButton(
            key: const Key('step2_continue_button'),
            title: langProvider.tr('continueAction'),
            onPressed: () {
              if (lotProvider.draftQuantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(langProvider.tr('invalidQuantityError')),
                  ),
                );
                return;
              }
              _nextStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(
    String key,
    String label,
    LotProvider lotProvider,
    bool isDark,
  ) {
    final isSelected = lotProvider.draftCondition == key;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return Expanded(
      child: InkWell(
        onTap: () => lotProvider.setCondition(key),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF132A1C) : const Color(0xFFDCFCE7))
                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: isSelected
                  ? activeGreen
                  : (isDark
                        ? AppColors.surfaceBorderDark
                        : AppColors.surfaceBorderLight),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? activeGreen
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ==================== STEP 3: ESTIMATED VALUE ====================
  Widget _buildStep3Estimate(
    bool isDark,
    LanguageProvider langProvider,
    LotProvider lotProvider,
  ) {
    final materialNames = {
      'copper': 'Copper (तांबा)',
      'aluminium': 'Aluminium (एल्युमिनियम)',
      'eWaste': 'E-Waste (इलेक्ट्रॉनिक्स PCBs)',
      'other': 'Other Scrap',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueSummaryCard(
            materialName:
                materialNames[lotProvider.draftMaterialKey] ?? 'Material',
            quantity: lotProvider.draftQuantity,
            unit: lotProvider.draftUnit,
            rate: lotProvider.currentRate,
            estimatedValue: lotProvider.currentEstimatedValue,
          ),
          const SizedBox(height: AppDimens.lg),

          // Optional notes
          AppCard(
            padding: const EdgeInsets.all(AppDimens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langProvider.tr('notes'),
                  style: AppTypography.titleMedium(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppDimens.sm),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: langProvider.tr('notesHint'),
                    hintStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF0C1711)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.surfaceBorderDark
                            : AppColors.surfaceBorderLight,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(AppDimens.md),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xxl),

          // Continue Button
          PrimaryButton(
            key: const Key('step3_continue_button'),
            title: langProvider.tr('continueAction'),
            onPressed: _nextStep,
          ),
        ],
      ),
    );
  }

  // ==================== STEP 4: REVIEW & CREATE ====================
  Widget _buildStep4Review(
    bool isDark,
    LanguageProvider langProvider,
    LotProvider lotProvider,
  ) {
    final materialNames = {
      'copper': 'Copper (तांबा)',
      'aluminium': 'Aluminium (एल्युमिनियम)',
      'eWaste': 'E-Waste (इलेक्ट्रॉनिक्स PCBs)',
      'other': 'Other Scrap',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LotReviewCard(
            photos: lotProvider.draftPhotos,
            materialName:
                materialNames[lotProvider.draftMaterialKey] ?? 'Material',
            quantity: lotProvider.draftQuantity,
            unit: lotProvider.draftUnit,
            rate: lotProvider.currentRate,
            estimatedValue: lotProvider.currentEstimatedValue,
            condition: lotProvider.draftCondition,
            notes: _notesController.text.trim(),
            onEdit: () => _goToStep(2),
          ),
          const SizedBox(height: AppDimens.xxl),

          // Create Lot Primary Button
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreenLight,
                ),
              ),
            )
          else
            PrimaryButton(
              key: const Key('step4_submit_button'),
              title: langProvider.tr('createLot'),
              icon: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => _submitLot(lotProvider),
            ),
        ],
      ),
    );
  }
}
