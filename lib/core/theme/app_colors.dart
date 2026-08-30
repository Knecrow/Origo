// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light Palette (Cloud-Lilac Porcelain & Soft Ceramic) ───────────────────
  static const Color lightBackground = Color(0xFFEBECF6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSecondary = Color(0xFFEFF1FA);
  static const Color lightAccent = Color(0xFF5360ED);
  static const Color lightAccentSoft = Color(0xFFE0E3FA);
  static const Color lightTextPrimary = Color(0xFF161828);
  static const Color lightTextMuted = Color(0xFF7E83A0);
  static const List<Color> lightPrimaryGradient = [Color(0xFF5E6BEE), Color(0xFF4350E0)];

  // Soft Ambient Ceramic Shadows
  static const Color lightShadowDark = Color(0xFFD3D6E8);
  static const Color lightShadowLight = Color(0xFFFFFFFF);

  // ── Dark Palette (Midnight Obsidian & Soft Glassmorphic Sheen) ─────────────
  static const Color darkBackground = Color(0xFF11121F);
  static const Color darkCard = Color(0xFF1B1D2E);
  static const Color darkCardSecondary = Color(0xFF22253B);
  static const Color darkAccent = Color(0xFF7582FF);
  static const Color darkAccentSoft = Color(0xFF252842);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextMuted = Color(0xFF888EA8);
  static const List<Color> darkPrimaryGradient = [Color(0xFF7582FF), Color(0xFF5360ED)];

  // Deep Obsidian Shadows
  static const Color darkShadowDark = Color(0xFF090A11);
  static const Color darkShadowLight = Color(0xFF272A42);

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF453A);
  static const Color success = Color(0xFF30D158);

  // ── Curated Ceramic Category Accents (Subtle & Elegant) ────────────────────
  static const Map<String, Color> categoryColors = {
    'Home': Color(0xFF3B82F6),
    'Garage': Color(0xFFFF6B4A),
    'Aviation': Color(0xFF9D4EDD),
    'Marine': Color(0xFF00B4D8),
    'Places': Color(0xFF10B981),
    'Sanctuary': Color(0xFFEC4899),
    'Experiences': Color(0xFF8B5CF6),
    'Collections': Color(0xFFF59E0B),
  };

  static Color getCategoryColor(String key) {
    return categoryColors[key] ?? const Color(0xFF7582FF);
  }

  // ── Luminous 3D Ceramic Gradients (Inspired by the Reference Image) ────────
  static const Map<String, List<Color>> categoryGradients = {
    'Home': [Color(0xFF3B82F6), Color(0xFF8B5CF6)], // Royal Cobalt & Lavender
    'Garage': [Color(0xFFFF5722), Color(0xFFFF9800)], // Sunset Coral & Amber
    'Aviation': [Color(0xFF7928CA), Color(0xFFFF0080)], // Twilight Violet & Magenta
    'Marine': [Color(0xFF00C6FF), Color(0xFF0072FF)], // Deep Cyan & Aqua
    'Places': [Color(0xFF059669), Color(0xFF34D399)], // Emerald & Mint
    'Sanctuary': [Color(0xFFFF4E50), Color(0xFFF9D423)], // Rose Lotus & Sunset Gold
    'Experiences': [Color(0xFF6366F1), Color(0xFFA855F7)], // Cosmic Indigo & Orchid
    'Collections': [Color(0xFFF59E0B), Color(0xFFFCD34D)], // Champagne Gold & Topaz
  };

  static List<Color> getCategoryGradient(String key) {
    return categoryGradients[key] ?? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
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
