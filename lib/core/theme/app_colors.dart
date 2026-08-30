// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light Palette (Apple iOS / One UI Porcelain) ───────────────────────────
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightAccent = Color(0xFF000000);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextMuted = Color(0xFF8E8E93);

  // Shadows
  static const Color lightShadowDark = Color(0xFFE5E5EA);
  static const Color lightShadowLight = Color(0xFFFFFFFF);

  // ── Dark Palette (Apple OLED True Black & Titanium Slate) ──────────────────
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkAccent = Color(0xFFFFFFFF);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextMuted = Color(0xFF8E8E93);

  // Shadows
  static const Color darkShadowDark = Color(0xFF000000);
  static const Color darkShadowLight = Color(0xFF2C2C2E);

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF453A);
  static const Color success = Color(0xFF30D158);

  // ── Monochromatic Category Colors (Stealth Titanium & Slate) ───────────────
  static const Map<String, Color> categoryColors = {
    'Home': Color(0xFF8E8E93),
    'Garage': Color(0xFF8E8E93),
    'Aviation': Color(0xFF8E8E93),
    'Marine': Color(0xFF8E8E93),
    'Places': Color(0xFF8E8E93),
    'Sanctuary': Color(0xFF8E8E93),
    'Experiences': Color(0xFF8E8E93),
    'Collections': Color(0xFF8E8E93),
  };

  static Color getCategoryColor(String key) {
    return const Color(0xFF8E8E93);
  }

  // ── Pure Cinematic OLED True Black Scrim Gradient ──────────────────────────
  static LinearGradient adaptiveScrim([
    Color? baseColor,
    bool isDark = true,
  ]) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.35),
              Colors.black.withValues(alpha: 0.92),
            ]
          : [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.28),
              Colors.black.withValues(alpha: 0.88),
            ],
      stops: const [0.15, 0.55, 1.0],
    );
  }
}

