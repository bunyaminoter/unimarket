import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/trade/viewmodel/trade_offer_viewmodel.dart';
import 'package:unimarket/models/product_model.dart';

class TradeOfferBottomSheet extends StatefulWidget {
  final ProductModel targetProduct;

  const TradeOfferBottomSheet({super.key, required this.targetProduct});

  @override
  State<TradeOfferBottomSheet> createState() => _TradeOfferBottomSheetState();
}

class _TradeOfferBottomSheetState extends State<TradeOfferBottomSheet> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<TradeOfferViewModel>().fetchMyEligibleProducts(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitOffer(BuildContext context, TradeOfferViewModel vm) async {
    final user = context.read<AuthViewModel>().user;
    if (user == null) return;

    final success = await vm.sendTradeOffer(
      offererId: user.uid,
      targetProduct: widget.targetProduct,
      message: _messageController.text.trim().isNotEmpty ? _messageController.text : null,
    );

    if (success && mounted) {
      if (!context.mounted) return;
      Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Takas teklifiniz satıcıya başarıyla iletildi!', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        top: AppSizes.lg,
        left: AppSizes.md,
        right: AppSizes.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      child: Consumer<TradeOfferViewModel>(
        builder: (context, vm, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutma çubuğu (Handlebar)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              Text('Takas Teklifi Gönder', style: GoogleFonts.poppins(fontSize: AppSizes.fontLg, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.xs),
              Text(
                '${widget.targetProduct.title} ürünü için kendi ilanlarınızdan birini seçin.',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: AppSizes.fontSm),
              ),
              const SizedBox(height: AppSizes.md),

              // Mesaj Alanı
              TextField(
                controller: _messageController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Satıcıya isteğe bağlı kısa bir mesaj bırakın...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: BorderSide(color: AppColors.primary)),
                ),
                style: GoogleFonts.poppins(fontSize: AppSizes.fontSm),
              ),
              const SizedBox(height: AppSizes.lg),

              // Ürün Listesi
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : vm.myEligibleProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textHint),
                                const SizedBox(height: AppSizes.sm),
                                Text(
                                  'Takas edilebilir aktif üretiminiz yok.\nÖnce takasa uygun yeni bir ilan verin.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: vm.myEligibleProducts.length,
                            itemBuilder: (context, index) {
                              final product = vm.myEligibleProducts[index];
                              final isSelected = vm.selectedProduct?.id == product.id;

                              return GestureDetector(
                                onTap: () => vm.selectProduct(product),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                                  padding: const EdgeInsets.all(AppSizes.xs),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? AppColors.success : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                                    color: isSelected ? AppColors.success.withValues(alpha: 0.05) : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                        child: product.primaryImage != null
                                            ? CachedNetworkImage(
                                                imageUrl: product.primaryImage!,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                                      ),
                                      const SizedBox(width: AppSizes.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(product.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: AppSizes.fontSm), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 2),
                                            Text(product.formattedPrice, style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: AppSizes.fontXs)),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.check_circle_rounded, color: AppColors.success),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              
              const SizedBox(height: AppSizes.md),

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(vm.errorMessage!, style: GoogleFonts.poppins(color: AppColors.error, fontSize: AppSizes.fontXs)),
                ),

              // Gönder Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (vm.isLoading || vm.selectedProduct == null) ? null : () => _submitOffer(context, vm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: vm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Teklifi Gönder', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: AppSizes.fontMd)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
