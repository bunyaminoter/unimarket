import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:unimarket/features/profile/widgets/profile_stat_card.dart';
import 'package:unimarket/features/profile/widgets/profile_info_tile.dart';
import 'package:unimarket/features/profile/widgets/profile_edit_sheet.dart';
import 'package:unimarket/models/user_model.dart';

/// Profil Ekranı
///
/// Kullanıcı bilgileri, istatistikler ve profil düzenleme.
/// AuthViewModel'den kullanıcı verisi çekilir.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Auth'daki kullanıcı bilgisini profil ViewModel'e aktar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final profileVM = context.read<ProfileViewModel>();
      if (authVM.user != null) {
        profileVM.setUser(authVM.user!);
      }
    });
  }

  void _showEditSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileEditSheet(user: user),
    );
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'Çıkış Yap',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
            child: Text(
              'Çıkış Yap',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthViewModel>().signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          Consumer<ProfileViewModel>(
            builder: (context, profileVM, _) {
              if (profileVM.user != null) {
                return IconButton(
                  onPressed: () =>
                      _showEditSheet(context, profileVM.user!),
                  icon: const Icon(Icons.edit_outlined),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, ProfileViewModel>(
        builder: (context, authVM, profileVM, _) {
          final user = profileVM.user ?? authVM.user;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                const SizedBox(height: AppSizes.md),

                // ── Avatar ve İsim ──────────────────────────
                _ProfileHeader(user: user),

                const SizedBox(height: AppSizes.xl),

                // ── İstatistikler ───────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ProfileStatCard(
                        icon: Icons.sell_rounded,
                        label: 'Satış',
                        value: '${user.totalSales}',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: ProfileStatCard(
                        icon: Icons.shopping_bag_rounded,
                        label: 'Alım',
                        value: '${user.totalPurchases}',
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: ProfileStatCard(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Takas',
                        value: '${user.totalTrades}',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xl),

                // ── Profil Bilgileri ─────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Bilgileri',
                        style: GoogleFonts.poppins(
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      ProfileInfoTile(
                        icon: Icons.email_outlined,
                        title: 'E-posta',
                        value: user.email,
                      ),
                      if (user.university != null &&
                          user.university!.isNotEmpty)
                        ProfileInfoTile(
                          icon: Icons.school_outlined,
                          title: 'Üniversite',
                          value: user.university!,
                        ),
                      if (user.department != null &&
                          user.department!.isNotEmpty)
                        ProfileInfoTile(
                          icon: Icons.menu_book_outlined,
                          title: 'Bölüm',
                          value: user.department!,
                        ),
                      if (user.phoneNumber != null &&
                          user.phoneNumber!.isNotEmpty)
                        ProfileInfoTile(
                          icon: Icons.phone_outlined,
                          title: 'Telefon',
                          value: user.phoneNumber!,
                        ),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        ProfileInfoTile(
                          icon: Icons.info_outline,
                          title: 'Hakkımda',
                          value: user.bio!,
                        ),
                      ProfileInfoTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Üyelik Tarihi',
                        value:
                            '${user.createdAt.day}.${user.createdAt.month}.${user.createdAt.year}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // ── Çıkış Yap Butonu ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Çıkış Yap',
                      style: GoogleFonts.poppins(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Profil Header (Avatar + İsim + Badge) ───────────────────
class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _AvatarInitials(
                          initials: user.initials,
                        ),
                      ),
                    )
                  : _AvatarInitials(initials: user.initials),
            ),
            // Öğrenci badge
            if (user.isStudentEmail)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSizes.md),

        // İsim
        Text(
          user.displayName,
          style: GoogleFonts.poppins(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        // E-posta
        Text(
          user.email,
          style: GoogleFonts.poppins(
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSizes.sm),

        // Rozetler
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.isStudentEmail)
              _Badge(
                icon: Icons.verified_rounded,
                label: 'Öğrenci',
                color: AppColors.success,
              ),
            if (user.isProfileComplete) ...[
              const SizedBox(width: AppSizes.sm),
              _Badge(
                icon: Icons.check_circle_rounded,
                label: 'Tam Profil',
                color: AppColors.info,
              ),
            ],
            if (user.rating > 0) ...[
              const SizedBox(width: AppSizes.sm),
              _Badge(
                icon: Icons.star_rounded,
                label: user.rating.toStringAsFixed(1),
                color: AppColors.warning,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  final String initials;
  const _AvatarInitials({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
