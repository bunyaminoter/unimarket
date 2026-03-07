import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/auth/widgets/auth_text_field.dart';
import 'package:unimarket/features/auth/widgets/auth_gradient_button.dart';
import 'package:unimarket/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:unimarket/models/user_model.dart';

/// Profil düzenleme bottom sheet.
/// Kullanıcı bilgilerini güncellemek için modal form.
class ProfileEditSheet extends StatefulWidget {
  final UserModel user;

  const ProfileEditSheet({super.key, required this.user});

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _universityController;
  late final TextEditingController _departmentController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user.displayName);
    _universityController =
        TextEditingController(text: widget.user.university ?? '');
    _departmentController =
        TextEditingController(text: widget.user.department ?? '');
    _phoneController =
        TextEditingController(text: widget.user.phoneNumber ?? '');
    _bioController =
        TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final profileVM = context.read<ProfileViewModel>();
    final success = await profileVM.updateProfile(
      uid: widget.user.uid,
      displayName: _nameController.text,
      university: _universityController.text,
      department: _departmentController.text,
      phoneNumber: _phoneController.text,
      bio: _bioController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil güncellendi!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutamak çizgisi
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              Text(
                'Profili Düzenle',
                style: GoogleFonts.poppins(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Ad Soyad
              AuthTextField(
                controller: _nameController,
                hintText: 'Ad Soyad',
                prefixIcon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad soyad gerekli.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSizes.md),

              // Üniversite
              AuthTextField(
                controller: _universityController,
                hintText: 'Üniversite',
                prefixIcon: Icons.account_balance_outlined,
              ),

              const SizedBox(height: AppSizes.md),

              // Bölüm
              AuthTextField(
                controller: _departmentController,
                hintText: 'Bölüm',
                prefixIcon: Icons.menu_book_outlined,
              ),

              const SizedBox(height: AppSizes.md),

              // Telefon
              AuthTextField(
                controller: _phoneController,
                hintText: 'Telefon numarası',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: AppSizes.md),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 150,
                style: GoogleFonts.poppins(fontSize: AppSizes.fontMd),
                decoration: InputDecoration(
                  hintText: 'Kendiniz hakkında kısa bir bilgi...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textHint,
                    fontSize: AppSizes.fontMd,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.info_outline),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Kaydet Butonu
              Consumer<ProfileViewModel>(
                builder: (context, profileVM, _) {
                  return AuthGradientButton(
                    text: 'Kaydet',
                    onPressed: _handleSave,
                    isLoading: profileVM.isLoading,
                    icon: Icons.check_rounded,
                  );
                },
              ),

              const SizedBox(height: AppSizes.md),

              // İptal
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontLg,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
