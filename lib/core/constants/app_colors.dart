import 'package:flutter/material.dart';

/// UniMarket Renk Paleti
/// Üniversite/öğrenci temasına uygun modern ve canlı renkler.
class AppColors {
  AppColors._();

  // ── Ana Renkler ──────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);       // Mor-mavi (Ana aksan)
  static const Color primaryDark = Color(0xFF524AE0);
  static const Color primaryLight = Color(0xFFA29BFE);

  // ── İkincil Renkler ──────────────────────────────────────
  static const Color secondary = Color(0xFF00B4D8);     // Turkuaz
  static const Color secondaryDark = Color(0xFF0096B7);
  static const Color secondaryLight = Color(0xFF90E0EF);

  // ── Accent / Vurgu ──────────────────────────────────────
  static const Color accent = Color(0xFFFF6B6B);        // Mercan kırmızı
  static const Color accentLight = Color(0xFFFF9F9F);

  // ── Nötr Renkler ─────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FD);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF16213E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E2746);

  // ── Metin Renkleri ───────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDarkPrimary = Color(0xFFECF0F1);
  static const Color textDarkSecondary = Color(0xFFBDC3C7);

  // ── Durum Renkleri ───────────────────────────────────────
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // ── Gradyanlar ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Gölge ────────────────────────────────────────────────
  static const Color shadow = Color(0x1A6C63FF);
  static const Color shadowDark = Color(0x33000000);
}
