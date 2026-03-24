import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/services/image_picker_service.dart';

/// Ürün Fotoğrafı Seçme Widget'ı
///
/// Kamera/galeri ile fotoğraf ekleme, önizleme ve silme.
/// Maksimum 5 fotoğraf destekler.
class ProductImagePicker extends StatelessWidget {
  final List<File> images;
  final ValueChanged<File> onImageAdded;
  final ValueChanged<int> onImageRemoved;
  final int maxImages;

  const ProductImagePicker({
    super.key,
    required this.images,
    required this.onImageAdded,
    required this.onImageRemoved,
    this.maxImages = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotoğraflar',
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontLg,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${images.length}/$maxImages',
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontSm,
                color: images.length >= maxImages
                    ? AppColors.error
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        // Fotoğraf grid
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Fotoğraf ekle butonu
              if (images.length < maxImages)
                _AddImageButton(
                  onTap: () async {
                    final pickerService = ImagePickerService();
                    final file = await pickerService.showImageSourcePicker(
                      context,
                    );
                    if (file != null) {
                      onImageAdded(file);
                    }
                  },
                ),
              // Seçili fotoğraflar
              ...images.asMap().entries.map((entry) {
                return _ImagePreview(
                  file: entry.value,
                  index: entry.key,
                  isFirst: entry.key == 0,
                  onRemove: () => onImageRemoved(entry.key),
                );
              }),
            ],
          ),
        ),

        if (images.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.xs),
            child: Text(
              'En az 1 fotoğraf eklemeniz önerilir.',
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontXs,
                color: AppColors.textHint,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Fotoğraf Ekle Butonu ────────────────────────────────────
class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: AppSizes.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Ekle',
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fotoğraf Önizleme ───────────────────────────────────────
class _ImagePreview extends StatelessWidget {
  final File file;
  final int index;
  final bool isFirst;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.file,
    required this.index,
    required this.isFirst,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: isFirst
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              isFirst ? AppSizes.radiusMd - 1 : AppSizes.radiusMd,
            ),
            child: Image.file(file, fit: BoxFit.cover, width: 100, height: 100),
          ),
        ),
        // "Kapak" rozeti
        if (isFirst)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                'Kapak',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        // Silme butonu
        Positioned(
          top: -4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
