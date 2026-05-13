import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/product/viewmodel/my_products_viewmodel.dart';
import 'package:unimarket/features/product/widgets/product_card.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyProductsViewModel>().loadMyProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'İlanlarım',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontLg,
          ),
        ),
      ),
      body: Consumer<MyProductsViewModel>(
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
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ElevatedButton(
                    onPressed: vm.loadMyProducts,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          if (vm.myProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Henüz hiç ilan vermedin.',
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontLg,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.addProduct),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('İlan Ver'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadMyProducts,
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
              itemCount: vm.myProducts.length,
              itemBuilder: (context, index) {
                final product = vm.myProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    // Ürün detay sayfasına git
                    context.push(AppRoutes.productDetail, extra: product).then((
                      _,
                    ) {
                      // Geri dönüldüğünde listeti yenile
                      if (context.mounted) {
                        context.read<MyProductsViewModel>().loadMyProducts();
                      }
                    });
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
