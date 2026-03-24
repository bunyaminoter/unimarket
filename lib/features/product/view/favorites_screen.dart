import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/product/viewmodel/favorites_viewmodel.dart';
import 'package:unimarket/features/product/widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Beğendiklerim',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppSizes.fontLg,
          ),
        ),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (vm.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Henüz bir ilan beğenmedin.',
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontLg,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadFavorites,
            color: AppColors.primary,
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSizes.md,
                crossAxisSpacing: AppSizes.md,
                childAspectRatio: 0.7,
              ),
              itemCount: vm.favorites.length,
              itemBuilder: (context, index) {
                final product = vm.favorites[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.push(AppRoutes.productDetail, extra: product).then((
                      _,
                    ) {
                      if (context.mounted) {
                        context.read<FavoritesViewModel>().loadFavorites();
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
