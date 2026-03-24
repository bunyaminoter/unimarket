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

/// Giriş Yap Ekranı
///
/// E-posta ve şifre ile giriş.
/// Şifremi unuttum ve kayıt ol yönlendirmeleri.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    authVM.clearError();

    final success = await authVM.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen önce e-posta adresinizi yazın.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.resetPassword(email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Şifre sıfırlama bağlantısı gönderildi!'
                : authVM.errorMessage ?? 'Bir hata oluştu.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
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
                    const SizedBox(height: AppSizes.xxl),

                    // Logo ve Başlık
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusXl,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    Center(
                      child: Text(
                        AppStrings.appName,
                        style: GoogleFonts.poppins(
                          fontSize: AppSizes.fontDisplay,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.xs),

                    Center(
                      child: Text(
                        'Hesabınıza giriş yapın',
                        style: GoogleFonts.poppins(
                          fontSize: AppSizes.fontLg,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.xxl),

                    // E-posta Alanı
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'E-posta adresiniz',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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

                    // Şifre Alanı
                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Şifreniz',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
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

                    const SizedBox(height: AppSizes.sm),

                    // Şifremi Unuttum
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Şifremi Unuttum',
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.md),

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

                    // Giriş Butonu
                    Consumer<AuthViewModel>(
                      builder: (context, authVM, _) {
                        return AuthGradientButton(
                          text: 'Giriş Yap',
                          onPressed: _handleLogin,
                          isLoading: authVM.isLoading,
                          icon: Icons.login_rounded,
                        );
                      },
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Ayırıcı
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.textHint.withValues(alpha: 0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                          ),
                          child: Text(
                            'veya',
                            style: GoogleFonts.poppins(
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.textHint.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // Öğrenci E-postası Bilgisi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            color: AppColors.info,
                            size: AppSizes.iconMd,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              'Öğrenci e-postası (.edu) ile kayıt olarak güvenilirliğinizi artırın!',
                              style: GoogleFonts.poppins(
                                fontSize: AppSizes.fontSm,
                                color: AppColors.info,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.xl),

                    // Kayıt Ol Yönlendirmesi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hesabınız yok mu? ',
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.fontMd,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.register),
                          child: Text(
                            'Kayıt Ol',
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
