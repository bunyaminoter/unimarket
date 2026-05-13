import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/models/product_model.dart';

/// Ürün Kartı Widget'ı
///
/// Ana sayfada ürünleri listeleyen kart.
/// Fotoğraf, başlık, fiyat, kategori ve takas rozeti gösterir.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün Fotoğrafı
            Expanded(
              child: _ProductImage(product: product, onFavorite: onFavorite, isFavorite: isFavorite),
            ),

            // Ürün Bilgileri
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.xs),

                  // Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      product.category.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Fiyat + Takas/Açık Artırma rozeti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          product.isAuction
                              ? product.formattedHighestBid
                              : product.formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.fontLg,
                            fontWeight: FontWeight.w700,
                            color: product.isAuction
                                ? const Color(0xFFFF6B6B)
                                : AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.isAuction)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.gavel_rounded,
                                color: Color(0xFFFF6B6B),
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.isAuctionActive ? 'Açık Artırma' : 'Bitti',
                                style: GoogleFonts.poppins(
                                  fontSize: AppSizes.fontXs,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (product.isTradeEligible)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horiz_rounded,
                                color: AppColors.success,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Takas',
                                style: GoogleFonts.poppins(
                                  fontSize: AppSizes.fontXs,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ürün Fotoğrafı ──────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const _ProductImage({required this.product, this.onFavorite, this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fotoğraf
          if (product.primaryImage != null)
            CachedNetworkImage(
              imageUrl: product.primaryImage!,
              fit: BoxFit.cover,
              placeholder: (_, _) => _ImagePlaceholder(),
              errorWidget: (_, _, _) => _ImagePlaceholder(),
            )
          else
            _ImagePlaceholder(),

          // Durum rozeti (satıldı / rezerve)
          if (!product.isActive)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: product.status == ProductStatus.sold
                        ? AppColors.error
                        : AppColors.warning,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    product.status.label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Favori butonu
          Positioned(
            top: AppSizes.sm,
            right: AppSizes.sm,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.error : AppColors.accent,
                  size: 18,
                ),
              ),
            ),
          ),

          // Kondisyon rozeti
          Positioned(
            top: AppSizes.sm,
            left: AppSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                product.condition.label,
                style: GoogleFonts.poppins(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.primary,
          size: AppSizes.iconXl,
        ),
      ),
    );
  }
}
