import 'package:flutter/material.dart';

/// Onboarding sayfası veri modeli.
class OnboardingPageModel {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;

  const OnboardingPageModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}
