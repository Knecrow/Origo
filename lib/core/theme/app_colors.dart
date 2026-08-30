// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light Palette (Apple iOS / One UI Porcelain) ───────────────────────────
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightAccent = Color(0xFF007AFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextMuted = Color(0xFF8E8E93);

  // Shadows
  static const Color lightShadowDark = Color(0xFFE5E5EA);
  static const Color lightShadowLight = Color(0xFFFFFFFF);

  // ── Dark Palette (Apple OLED True Black & System Gray) ─────────────────────
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkAccent = Color(0xFF0A84FF);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextMuted = Color(0xFF8E8E93);

  // Shadows
  static const Color darkShadowDark = Color(0xFF000000);
  static const Color darkShadowLight = Color(0xFF2C2C2E);

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF453A);
  static const Color success = Color(0xFF30D158);

  // ── Category Accent Colors (The Elite 8) ───────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'Home': Color(0xFF0A84FF),
    'Garage': Color(0xFFFF9F0A),
    'Aviation': Color(0xFFBF5AF2),
    'Marine': Color(0xFF64D2FF),
    'Places': Color(0xFF30D158),
    'Sanctuary': Color(0xFF32D74B),
    'Experiences': Color(0xFFFF453A),
    'Collections': Color(0xFFFFD60A),
  };

  static Color getCategoryColor(String key) {
    return categoryColors[key] ?? const Color(0xFF0A84FF);
  }

  // ── Smart Adaptive Cinematic Scrim Gradient ────────────────────────────────
  static LinearGradient adaptiveScrim(Color baseColor, {bool isDark = true}) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.black.withValues(alpha: 0.08),
              baseColor.withValues(alpha: 0.24),
              Colors.black.withValues(alpha: 0.88),
            ]
          : [
              Colors.black.withValues(alpha: 0.05),
              baseColor.withValues(alpha: 0.20),
              Colors.black.withValues(alpha: 0.82),
            ],
      stops: const [0.0, 0.48, 1.0],
    );
  }
}
