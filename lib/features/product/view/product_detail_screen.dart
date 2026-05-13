import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/product/viewmodel/product_detail_viewmodel.dart';
import 'package:unimarket/features/product/viewmodel/favorites_viewmodel.dart';
import 'package:unimarket/features/trade/view/trade_offer_bottom_sheet.dart';
import 'package:unimarket/features/product/view/edit_product_bottom_sheet.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarket/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:unimarket/features/auction/view/auction_section_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel initialProduct;

  const ProductDetailScreen({super.key, required this.initialProduct});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _pageController;
  int _currentImageIndex = 0;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailViewModel>().initProduct(widget.initialProduct);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Takas Teklif Et Bottom Sheet Gösterimi
  void _showTradeOfferSheet(BuildContext context, ProductModel targetProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TradeOfferBottomSheet(targetProduct: targetProduct),
    );
  }

  /// Satıcıya Mesaj Atma İşlemi
  Future<void> _openChat(BuildContext context, ProductModel product) async {
    try {
      final chatVM = context.read<ChatDetailViewModel>();
      final currentUser = context.read<AuthViewModel>().user;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sohbet başlatmak için giriş yapmalısınız.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        return;
      }

      // Sohbeti başlat veya varolanı getir
      final chatId = await chatVM.startOrGetChat(
        product.sellerId,
        productId: product.id,
      );

      if (context.mounted) {
        final theOtherUser = UserModel(
          uid: product.sellerId,
          displayName: product.sellerName,
          email: '', // Detail için şart değil
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        context.pushNamed(
          'chatDetail',
          pathParameters: {'chatId': chatId},
          extra: theOtherUser,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sohbet başlatılamadı: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailViewModel>(
      builder: (context, vm, child) {
        final product = vm.product ?? widget.initialProduct;
        final currentUser = context.read<AuthViewModel>().user;
        final isOwner = currentUser?.uid == product.sellerId;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, product, vm),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(product),
                _buildProductDetails(product),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomActions(context, product, isOwner),
        );
      },
    );
  }

  /// Üst Navigasyon Çubuğu
  AppBar _buildAppBar(
    BuildContext context,
    ProductModel product,
    ProductDetailViewModel vm,
  ) {
    return AppBar(
      title: Text(
        'İlan Detayı',
        style: GoogleFonts.poppins(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Consumer<FavoritesViewModel>(
          builder: (context, favVM, child) {
            final isFavorite = favVM.isFavorite(product.id);
            return IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? AppColors.error : AppColors.textPrimary,
              ),
              onPressed: _isTogglingFavorite 
                ? null 
                : () async {
                  setState(() => _isTogglingFavorite = true);
                  try {
                    final currentIsFav = favVM.isFavorite(product.id);
                    await favVM.toggleFavorite(product);
                    if (mounted) {
                      context.read<ProductDetailViewModel>().updateLocalFavoriteCount(!currentIsFav);
                    }
                  } finally {
                    if (mounted) setState(() => _isTogglingFavorite = false);
                  }
                },
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.share_rounded, color: AppColors.textPrimary),
          onPressed: () {
            // Paylaşma mantığı (İsteğe bağlı)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('İlan paylaşılmak üzere kopyalandı!'),
                backgroundColor: AppColors.secondary,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Fotoğraf Galerisi Kaydırıcısı (Carousel)
  Widget _buildImageCarousel(ProductModel product) {
    if (product.images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: product.images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: product.images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade100,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.textHint,
                  ),
                ),
              );
            },
          ),
        ),
        // Nokta (Dot) Göstergeleri
        if (product.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Ürün Bilgileri ve Satıcı Kartı
  Widget _buildProductDetails(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fiyat ve Kalp sayısı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.formattedPrice,
                style: GoogleFonts.poppins(
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.viewCount}',
                    style: GoogleFonts.poppins(
                      color: AppColors.textHint,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.favoriteCount}',
                    style: GoogleFonts.poppins(
                      color: AppColors.textHint,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // Başlık
          Text(
            product.title,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Kategori, Kondisyon Rozetleri
          Row(
            children: [
              _buildBadge(
                product.category.displayName,
                Icons.category_outlined,
                AppColors.secondary.withValues(alpha: 0.1),
                AppColors.secondary,
              ),
              const SizedBox(width: AppSizes.sm),
              _buildBadge(
                product.condition.label,
                Icons.info_outline_rounded,
                Colors.blue.withValues(alpha: 0.1),
                Colors.blue.shade700,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Satıcı Bilgileri
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: product.sellerPhotoUrl != null
                      ? NetworkImage(product.sellerPhotoUrl!)
                      : null,
                  child: product.sellerPhotoUrl == null
                      ? Icon(Icons.person_outline, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.sellerName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.fontMd,
                        ),
                      ),
                      if (product.location != null)
                        Text(
                          product.location!,
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.fontSm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified,
                  color: AppColors.success,
                  size: AppSizes.iconMd,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Açık Artırma Bölümü
          if (product.isAuction)
            AuctionSectionWidget(product: product),

          // Açıklama
          Text(
            'Açıklama',
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            product.description,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Takas Bilgisi
          if (product.isTradeEligible) ...[
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Takasa Uygun',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          product.tradeDescription?.isNotEmpty == true
                              ? product.tradeDescription!
                              : 'Sıradan takas tekliflerine açık.',
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.fontXs,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(
    String text,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Alt Eylem Butonları (Takas Teklif Et ve Mesaj At)
  Widget _buildBottomActions(
    BuildContext context,
    ProductModel product,
    bool isOwner,
  ) {
    if (isOwner) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => EditProductBottomSheet(product: product),
            );

            if (result == 'deleted' && context.mounted) {
              Navigator.pop(context);
            } else if (result == 'sold' && context.mounted) {
              Navigator.pop(context); // Satıldı — detaydan çık
            } else if (result == true && context.mounted) {
              // Güncellendiyse
            }
          },
          icon: const Icon(Icons.edit_outlined),
          label: Text(
            'İlanımı Yönet',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Takas Butonu
            if (product.isTradeEligible)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: OutlinedButton.icon(
                    onPressed: () => _showTradeOfferSheet(context, product),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                    label: Text(
                      'Takas',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(color: AppColors.success, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                    ),
                  ),
                ),
              ),

            // Satın Al / Mesaj At Butonu
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _openChat(context, product),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                label: Text(
                  'Satıcıya Mesaj At',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
