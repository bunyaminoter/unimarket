import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/core/constants/app_strings.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/auth/widgets/auth_text_field.dart';
import 'package:unimarket/features/auth/widgets/auth_gradient_button.dart';

/// Kayıt Ol Ekranı
///
/// E-posta, şifre, ad soyad, üniversite ve bölüm bilgileriyle kayıt.
/// Öğrenci e-postası (.edu) ile kayıt önerilir.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _universityController = TextEditingController();
  final _departmentController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen kullanım koşullarını kabul edin.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    authVM.clearError();

    final success = await authVM.register(
      email: _emailController.text,
      password: _passwordController.text,
      displayName: _nameController.text,
      university: _universityController.text.isNotEmpty
          ? _universityController.text
          : null,
      department: _departmentController.text.isNotEmpty
          ? _departmentController.text
          : null,
    );

    if (success && mounted) {
      // Kayıt başarılı, e-posta doğrulama SnackBar göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kayıt başarılı! Doğrulama bağlantısı e-postanıza gönderildi.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSizes.lg),

                    // Geri butonu & Başlık
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hesap Oluştur',
                                style: GoogleFonts.poppins(
                                  fontSize: AppSizes.fontXxl,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                AppStrings.appTagline,
                                style: GoogleFonts.poppins(
                                  fontSize: AppSizes.fontSm,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.xl),

                    // ── Kişisel Bilgiler ─────────────────────
                    _SectionHeader(
                      icon: Icons.person_outline_rounded,
                      title: 'Kişisel Bilgiler',
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Ad Soyad
                    AuthTextField(
                      controller: _nameController,
                      hintText: 'Ad Soyad',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ad soyad gerekli.';
                        }
                        if (value.trim().length < 3) {
                          return 'Ad soyad en az 3 karakter olmalı.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.md),

                    // E-posta
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'E-posta (öğrenci e-postası önerilir)',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'E-posta adresi gerekli.';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return 'Geçerli bir e-posta adresi girin.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Öğrenci e-postası bilgisi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: AppSizes.iconSm,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              '.edu uzantılı e-posta ile profilinizde "Doğrulanmış Öğrenci" rozeti alırsınız.',
                              style: GoogleFonts.poppins(
                                fontSize: AppSizes.fontXs + 1,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // ── Güvenlik ─────────────────────────────
                    _SectionHeader(
                      icon: Icons.lock_outline_rounded,
                      title: 'Güvenlik',
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Şifre
                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Şifre (en az 6 karakter)',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre gerekli.';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalı.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Şifre Tekrar
                    AuthTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Şifre Tekrar',
                      prefixIcon: Icons.lock_reset_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre tekrarı gerekli.';
                        }
                        if (value != _passwordController.text) {
                          return 'Şifreler eşleşmiyor.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // ── Üniversite Bilgileri (Opsiyonel) ──────
                    _SectionHeader(
                      icon: Icons.school_outlined,
                      title: 'Üniversite Bilgileri',
                      subtitle: '(Opsiyonel)',
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Üniversite
                    AuthTextField(
                      controller: _universityController,
                      hintText: 'Üniversite adı',
                      prefixIcon: Icons.account_balance_outlined,
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Bölüm
                    AuthTextField(
                      controller: _departmentController,
                      hintText: 'Bölüm adı',
                      prefixIcon: Icons.menu_book_outlined,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Kullanım koşulları checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: AppSizes.fontSm,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'Kayıt olarak '),
                                  TextSpan(
                                    text: 'Kullanım Koşulları',
                                    style: GoogleFonts.poppins(
                                      fontSize: AppSizes.fontSm,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' ve '),
                                  TextSpan(
                                    text: 'Gizlilik Politikası',
                                    style: GoogleFonts.poppins(
                                      fontSize: AppSizes.fontSm,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: '\'nı kabul ediyorum.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Hata Mesajı
                    Consumer<AuthViewModel>(
                      builder: (context, authVM, _) {
                        if (authVM.errorMessage != null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSizes.md),
                            margin: const EdgeInsets.only(bottom: AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: AppSizes.iconSm,
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Expanded(
                                  child: Text(
                                    authVM.errorMessage!,
                                    style: GoogleFonts.poppins(
                                      fontSize: AppSizes.fontSm,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Kayıt Ol Butonu
                    Consumer<AuthViewModel>(
                      builder: (context, authVM, _) {
                        return AuthGradientButton(
                          text: 'Kayıt Ol',
                          onPressed: _handleRegister,
                          isLoading: authVM.isLoading,
                          icon: Icons.person_add_rounded,
                          gradientColors: const [
                            Color(0xFF00B894),
                            Color(0xFF55E6C1),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppSizes.xl),

                    // Giriş Yap Yönlendirmesi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Zaten hesabınız var mı? ',
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.fontMd,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            'Giriş Yap',
                            style: GoogleFonts.poppins(
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.xs + 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSizes.iconSm),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: AppSizes.xs),
          Text(
            subtitle!,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontSm,
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }
}
