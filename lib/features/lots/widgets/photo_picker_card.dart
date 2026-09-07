import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Large card for capturing/picking photos and reviewing thumbnails
class PhotoPickerCard extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final ValueChanged<int> onRemovePhoto;
  final ValueChanged<String>? onSelectPreset;

  const PhotoPickerCard({
    super.key,
    required this.photos,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onRemovePhoto,
    this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeGreen = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main photo drop/action card
        AppCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.xxl,
            horizontal: AppDimens.lg,
          ),
          child: Center(
            child: Column(
              children: [
                // Big camera icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F3020)
                        : const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    size: 32,
                    color: activeGreen,
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                Text(
                  'फ़ोटो जोड़ें (Add Photos)',
                  style: AppTypography.titleLarge(isDark)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'अपने e-waste की साफ़ फ़ोटो लें या गैलरी से चुनें',
                  style: AppTypography.bodyMedium(isDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.lg),

                // Camera & Gallery action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusMd,
                          ),
                        ),
                      ),
                      onPressed: onCameraTap,
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text(
                        'Camera',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white
                            : AppColors.primaryDarkShade,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.surfaceBorderDark
                              : AppColors.surfaceBorderLight,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusMd,
                          ),
                        ),
                      ),
                      onPressed: onGalleryTap,
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: const Text(
                        'Gallery',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Thumbnail strip if photos are present
        if (photos.isNotEmpty) ...[
          const SizedBox(height: AppDimens.lg),
          Text(
            'चयनित फ़ोटो (${photos.length})',
            style: AppTypography.titleMedium(isDark)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.sm),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimens.sm),
              itemBuilder: (context, index) {
                final photo = photos[index];

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF162A1F)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(color: activeGreen, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_rounded,
                            size: 32,
                            color: activeGreen,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            photo.split('/').last,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFF166534),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => onRemovePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
