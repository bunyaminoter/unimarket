import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/core/constants/app_strings.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/home/viewmodel/home_viewmodel.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/features/product/widgets/product_card.dart';
import 'package:unimarket/features/home/widgets/app_drawer.dart';

/// Ana Sayfa Ekranı
/// Ürün listesi, kategori filtreleri ve hızlı erişim kartları.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.xs + 2),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: AppSizes.iconSm + 2,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Sonraki fazda arama özelliği eklenecek
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              // Sonraki fazda bildirimler eklenecek
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          // Profil butonu
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              margin: const EdgeInsets.only(right: AppSizes.md),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Consumer<AuthViewModel>(
                builder: (context, authVM, _) {
                  final name = authVM.user?.displayName ?? '';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                  return Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, homeVM, _) {
          return RefreshIndicator(
            onRefresh: homeVM.refreshProducts,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Karşılama mesajı (kullanıcı adıyla kişiselleştirilmiş)
                        Consumer<AuthViewModel>(
                          builder: (context, authVM, _) {
                            final name = authVM.user?.displayName;
                            return Text(
                              name != null
                                  ? 'Hoş geldin, $name! 👋'
                                  : AppStrings.welcomeMessage,
                              style: theme.textTheme.headlineMedium,
                            );
                          },
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          AppStrings.appTagline,
                          style: theme.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: AppSizes.md),

                        // Kategoriler başlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Kategoriler',
                                style: theme.textTheme.titleLarge),
                            if (homeVM.selectedCategory != null)
                              TextButton(
                                onPressed: () => homeVM.selectCategory(null),
                                child: const Text('Tümünü Gör'),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),

                        // Kategori çipleri
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: ProductCategory.values.length,
                            separatorBuilder: (context, _) =>
                                const SizedBox(width: AppSizes.sm),
                            itemBuilder: (context, index) {
                              final category = ProductCategory.values[index];
                              final isSelected =
                                  homeVM.selectedCategory == category;
                              return GestureDetector(
                                onTap: () => homeVM.selectCategory(category),
                                child: _CategoryChip(
                                  label: category.displayName,
                                  isSelected: isSelected,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: AppSizes.xl),

                        // Son İlanlar başlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              homeVM.selectedCategory != null
                                  ? '${homeVM.selectedCategory!.label} İlanları'
                                  : 'Son İlanlar',
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Yükleniyor veya Hata veya Boş Durum
                        if (homeVM.isLoading && !homeVM.isRefreshing)
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        else if (homeVM.errorMessage != null)
                          _ErrorView(
                            message: homeVM.errorMessage!,
                            onRetry: homeVM.loadProducts,
                          )
                        else if (!homeVM.hasProducts)
                          _EmptyView(
                            isFiltered: homeVM.selectedCategory != null,
                            onClearFilter: () => homeVM.selectCategory(null),
                          ),
                      ],
                    ),
                  ),
                ),

                // Gerçek Ürün Kartları (GridView)
                if (homeVM.hasProducts && !homeVM.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSizes.md,
                        crossAxisSpacing: AppSizes.md,
                        childAspectRatio: 0.7, // Genişlik / Yükseklik oranı
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = homeVM.products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              context.push(AppRoutes.productDetail, extra: product);
                            },
                            onFavorite: () {
                              // Sonraki faz: Favoriye ekleme
                            },
                          );
                        },
                        childCount: homeVM.products.length,
                      ),
                    ),
                  ),

                // Alt boşluk
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xxl)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Yardımcı Widget'lar ─────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CategoryChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs + 2,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSizes.sm),
            Text(message, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: AppSizes.sm),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onClearFilter;

  const _EmptyView({required this.isFiltered, required this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xxl),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppSizes.md),
            Text(
              isFiltered
                  ? 'Bu kategoride henüz ilan yok.'
                  : 'Henüz hiç ilan verilmemiş.',
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontLg,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              isFiltered
                  ? 'Farklı bir kategori seçebilirsin.'
                  : 'İlk ilanı sen ver!',
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontSm,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            if (isFiltered) ...[
              const SizedBox(height: AppSizes.md),
              TextButton.icon(
                onPressed: onClearFilter,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Filtreyi Temizle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
