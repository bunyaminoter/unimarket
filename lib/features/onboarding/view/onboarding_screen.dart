import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/core/constants/app_strings.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/onboarding/model/onboarding_page_model.dart';
import 'package:unimarket/features/onboarding/widgets/onboarding_page_widget.dart';
import 'package:unimarket/features/onboarding/widgets/onboarding_dot_indicator.dart';

/// Onboarding (Tanıtım) Ekranı
/// Kullanıcıya uygulamanın temel özelliklerini gösteren 3 sayfalık slider.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _buttonAnimController;
  int _currentPage = 0;

  final List<OnboardingPageModel> _pages = const [
    OnboardingPageModel(
      icon: Icons.sell_rounded,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      gradientColors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
    ),
    OnboardingPageModel(
      icon: Icons.verified_user_rounded,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      gradientColors: [Color(0xFF00B4D8), Color(0xFF0096B7)],
    ),
    OnboardingPageModel(
      icon: Icons.swap_horizontal_circle_rounded,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      gradientColors: [Color(0xFF00B894), Color(0xFF55E6C1)],
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    if (_isLastPage) {
      _buttonAnimController.forward();
    } else {
      _buttonAnimController.reverse();
    }
  }

  void _goToNextPage() {
    if (_isLastPage) {
      _navigateToLogin();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToLogin() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Üst kısım: Atla butonu
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: AnimatedOpacity(
                  opacity: _isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: TextButton(
                    onPressed: _isLastPage ? null : _navigateToLogin,
                    child: Text(
                      AppStrings.skip,
                      style: GoogleFonts.poppins(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sayfa İçeriği
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),

            // Alt kısım: Dot göstergesi ve buton
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  // Dot Göstergesi
                  OnboardingDotIndicator(
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                  ),

                  const SizedBox(height: AppSizes.xl),

                  // Ana Buton
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _pages[_currentPage].gradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage].gradientColors.first
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _goToNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLastPage
                                  ? AppStrings.getStarted
                                  : AppStrings.next,
                              style: GoogleFonts.poppins(
                                fontSize: AppSizes.fontLg,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Icon(
                              _isLastPage
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
