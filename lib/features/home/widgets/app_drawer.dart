import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/home/viewmodel/home_viewmodel.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final homeVM = context.watch<HomeViewModel>();
    final user = authVM.user;
    final name = user?.displayName ?? 'Öğrenci';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                initial,
                style: GoogleFonts.poppins(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            accountName: Text(
              name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontMd,
              ),
            ),
            accountEmail: Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: AppSizes.fontSm,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.list_alt_rounded,
                  title: 'Tüm Ürünler',
                  isSelected: !homeVM.showOnlyTradeable,
                  onTap: () {
                    if (homeVM.showOnlyTradeable) {
                      homeVM.toggleTradeableFilter();
                    }
                    Navigator.pop(context); // Drawer'ı kapat
                  },
                ),
                _DrawerItem(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Takasa Açık Ürünler',
                  isSelected: homeVM.showOnlyTradeable,
                  onTap: () {
                    if (!homeVM.showOnlyTradeable) {
                      homeVM.toggleTradeableFilter();
                    }
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'İlan Ver',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.addProduct);
                  },
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'İlanlarım',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.myProducts);
                  },
                ),
                _DrawerItem(
                  icon: Icons.favorite_border_rounded,
                  title: 'Beğendiklerim',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.favorites);
                  },
                ),
                _DrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Mesajlarım',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.chatList);
                  },
                ),
                _DrawerItem(
                  icon: Icons.handshake_outlined,
                  title: 'Tekliflerim',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.myOffers);
                  },
                ),
                _DrawerItem(
                  icon: Icons.gavel_rounded,
                  title: 'Açık Artırmalar',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.auctions);
                  },
                ),
              ],
            ),
          ),

          // Çıkış Yap Butonu
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(context); // Drawer'ı kapat
                await authVM.signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                'Çıkış Yap',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
      onTap: onTap,
    );
  }
}
