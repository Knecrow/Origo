// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light Palette (Cloud-Lilac Porcelain & Soft Ceramic) ───────────────────
  static const Color lightBackground = Color(0xFFEBECF6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFE2E4F2);
  static const Color lightAccent = Color(0xFF5360ED);
  static const Color lightAccentSoft = Color(0xFFE0E3FA);
  static const Color lightTextPrimary = Color(0xFF161828);
  static const Color lightTextMuted = Color(0xFF7E83A0);

  // Soft Ambient Ceramic Shadows
  static const Color lightShadowDark = Color(0xFFD3D6E8);
  static const Color lightShadowLight = Color(0xFFFFFFFF);

  // ── Dark Palette (Midnight Obsidian & Soft Glassmorphic Sheen) ─────────────
  static const Color darkBackground = Color(0xFF11121F);
  static const Color darkCard = Color(0xFF1B1D2E);
  static const Color darkCardSecondary = Color(0xFF151624);
  static const Color darkAccent = Color(0xFF7582FF);
  static const Color darkAccentSoft = Color(0xFF252842);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextMuted = Color(0xFF888EA8);

  // Deep Obsidian Shadows
  static const Color darkShadowDark = Color(0xFF090A11);
  static const Color darkShadowLight = Color(0xFF272A42);

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF453A);
  static const Color success = Color(0xFF30D158);

  // ── Curated Ceramic Category Accents (Subtle & Elegant) ────────────────────
  static const Map<String, Color> categoryColors = {
    'Home': Color(0xFF5360ED),
    'Garage': Color(0xFF7582FF),
    'Aviation': Color(0xFF8E99F3),
    'Marine': Color(0xFF5B78E5),
    'Places': Color(0xFF6366F1),
    'Sanctuary': Color(0xFF6B7FF5),
    'Experiences': Color(0xFF7E8BFF),
    'Collections': Color(0xFF8B96FF),
  };

  static Color getCategoryColor(String key) {
    return categoryColors[key] ?? const Color(0xFF7582FF);
  }

  // ── Smooth Cinematic Ambient Scrim ─────────────────────────────────────────
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
              const Color(0xFF11121F).withValues(alpha: 0.35),
              const Color(0xFF11121F).withValues(alpha: 0.94),
            ]
          : [
              Colors.transparent,
              const Color(0xFF161828).withValues(alpha: 0.25),
              const Color(0xFF161828).withValues(alpha: 0.88),
            ],
      stops: const [0.15, 0.55, 1.0],
    );
  }
}
