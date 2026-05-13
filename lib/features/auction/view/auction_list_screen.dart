import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/auction/viewmodel/auction_list_viewmodel.dart';
import 'package:unimarket/features/product/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarket/core/router/app_router.dart';

/// Açık Artırmalar Sayfası
///
/// Sadece açık artırmadaki ürünleri listeler.
class AuctionListScreen extends StatefulWidget {
  const AuctionListScreen({super.key});

  @override
  State<AuctionListScreen> createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends State<AuctionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionListViewModel>().loadAuctionProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '🔨 Açık Artırmalar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontLg,
          ),
        ),
      ),
      body: Consumer<AuctionListViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSizes.sm),
                  Text(vm.errorMessage!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: AppSizes.sm),
                  ElevatedButton(
                    onPressed: vm.loadAuctionProducts,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (vm.auctionProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Henüz açık artırmada ürün yok.',
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontLg,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'İlan verirken "Açık Artırma" seçeneğini aktif edebilirsiniz.',
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadAuctionProducts,
            color: AppColors.primary,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSizes.md,
                crossAxisSpacing: AppSizes.md,
                childAspectRatio: 0.7,
              ),
              itemCount: vm.auctionProducts.length,
              itemBuilder: (context, index) {
                final product = vm.auctionProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.push(
                      '/product/${product.id}',
                      extra: product,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
