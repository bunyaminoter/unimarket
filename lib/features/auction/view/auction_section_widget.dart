import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/auction/viewmodel/auction_viewmodel.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/models/product_model.dart';

/// Ürün detay sayfasında gösterilen açık artırma bölümü.
/// Geri sayım, en yüksek teklif, teklif verme ve teklif geçmişi.
class AuctionSectionWidget extends StatefulWidget {
  final ProductModel product;
  const AuctionSectionWidget({super.key, required this.product});

  @override
  State<AuctionSectionWidget> createState() => _AuctionSectionWidgetState();
}

class _AuctionSectionWidgetState extends State<AuctionSectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auctionVM = context.read<AuctionViewModel>();
      auctionVM.startCountdown(widget.product);
      auctionVM.watchBids(widget.product.id);
    });
  }

  void _showBidDialog(BuildContext context, ProductModel product) {
    final bidController = TextEditingController();
    final currentUser = context.read<AuthViewModel>().user;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Teklif Ver', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minimum teklif: ₺${product.minimumBidAmount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bidController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                prefixText: '₺ ',
                hintText: product.minimumBidAmount.toStringAsFixed(0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          Consumer<AuctionViewModel>(
            builder: (context, vm, _) => ElevatedButton(
              onPressed: vm.isPlacingBid
                  ? null
                  : () async {
                      final amount = double.tryParse(bidController.text);
                      if (amount == null) return;
                      final success = await vm.placeBid(
                        productId: product.id,
                        bidderId: currentUser.uid,
                        bidderName: currentUser.displayName,
                        amount: amount,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? 'Teklifiniz verildi!' : (vm.errorMessage ?? 'Hata'),
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: success ? AppColors.success : AppColors.error,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: vm.isPlacingBid
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Teklif Ver', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionViewModel>(
      builder: (context, auctionVM, _) {
        final product = widget.product;
        final currentUser = context.read<AuthViewModel>().user;
        final isOwner = currentUser?.uid == product.sellerId;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.lg),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                const Color(0xFFFF6B6B).withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Açık Artırma',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: AppSizes.fontLg, color: const Color(0xFFFF6B6B)),
                        ),
                        Text(
                          'Taban Fiyat: ${product.formattedPrice}',
                          style: GoogleFonts.poppins(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              // Geri Sayım ve En Yüksek Teklif
              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.timer_outlined,
                      label: 'Kalan Süre',
                      value: auctionVM.formattedTimeLeft,
                      color: auctionVM.isExpired ? AppColors.error : const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.trending_up_rounded,
                      label: 'En Yüksek Teklif',
                      value: product.formattedHighestBid,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // Teklif Sayısı
              Center(
                child: Text(
                  '${product.bidCount} teklif verildi',
                  style: GoogleFonts.poppins(fontSize: AppSizes.fontSm, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Süre dolmuş bilgisi
              if (auctionVM.isExpired || product.auctionEnded) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    product.bidCount > 0
                        ? '⏰ Açık artırma sona erdi. En yüksek teklif: ${product.formattedHighestBid} (${product.highestBidderName})'
                        : '⏰ Açık artırma teklif süresi doldu. Ürün normal satışa devam ediyor.',
                    style: GoogleFonts.poppins(fontSize: AppSizes.fontSm, color: Colors.orange.shade800, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]
              // Teklif Ver butonu (sahip değilse ve süre dolmamışsa)
              else if (!isOwner) ...[
                // En yüksek teklif zaten bu kullanıcıya aitse
                if (product.highestBidderId == currentUser?.uid) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'En yüksek teklifi siz verdiniz!',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                              fontSize: AppSizes.fontSm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showBidDialog(context, product),
                      icon: const Icon(Icons.gavel_rounded, size: 20),
                      label: Text('Teklif Ver', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
                      ),
                    ),
                  ),
                ],
              ],

              // Teklif Geçmişi
              if (auctionVM.bids.isNotEmpty) ...[
                const SizedBox(height: AppSizes.md),
                Text('Teklif Geçmişi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: AppSizes.fontMd)),
                const SizedBox(height: AppSizes.sm),
                ...auctionVM.bids.take(5).map((bid) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(bid.bidderName.isNotEmpty ? bid.bidderName[0].toUpperCase() : '?',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(bid.bidderName, style: GoogleFonts.poppins(fontSize: AppSizes.fontSm), overflow: TextOverflow.ellipsis),
                      ),
                      Text(bid.formattedAmount,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: AppSizes.fontSm, color: AppColors.primary)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: AppSizes.fontXs, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: AppSizes.fontSm, color: color)),
        ],
      ),
    );
  }
}
