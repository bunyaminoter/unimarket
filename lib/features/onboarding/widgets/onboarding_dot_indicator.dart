import 'package:flutter/material.dart';
import 'package:unimarket/core/constants/app_colors.dart';

/// Onboarding dot göstergesi.
/// Aktif sayfa genişleyerek gradient renk alır, diğerleri küçük nokta olarak kalır.
class OnboardingDotIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingDotIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }
}
