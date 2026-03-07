import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/onboarding/model/onboarding_page_model.dart';

/// Onboarding tek sayfa widget'ı.
/// Gradient arka plan, ikon, başlık ve açıklama gösterir.
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageModel page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gradient çevrimli ikon alanı
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  page.gradientColors.first.withValues(alpha: 0.15),
                  page.gradientColors.last.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: page.gradientColors.first.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              size: 72,
              color: page.gradientColors.first,
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          // Başlık
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontXxl + 4,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Açıklama
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
