// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light Palette ──────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFE9EFF5);
  static const Color lightCard = Color(0xFFF4F8FB);
  static const Color lightAccent = Color(0xFF36536F);
  static const Color lightTextPrimary = Color(0xFF1C2E40);
  static const Color lightTextMuted = Color(0xFF7A8D9E);

  // Neumorphic shadows (light theme)
  static const Color lightShadowDark = Color(0xFFCAD5DF);
  static const Color lightShadowLight = Color(0xFFFFFFFF);

  // ── Dark Palette (High Contrast Stealth Obsidian & Elevated Midnight Slate) ─
  static const Color darkBackground = Color(0xFF090D13);
  static const Color darkCard = Color(0xFF1D2634);
  static const Color darkAccent = Color(0xFF6B9EC7);
  static const Color darkTextPrimary = Color(0xFFF0F5FA);
  static const Color darkTextMuted = Color(0xFF8CA1B6);

  // Neumorphic shadows (dark theme)
  static const Color darkShadowDark = Color(0xFF05080C);
  static const Color darkShadowLight = Color(0xFF1B2433);

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFE05B5B);
  static const Color success = Color(0xFF5BB8A0);

  // ── Category Accent Colors ─────────────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'Home': Color(0xFF7B9EC2),
    'Places': Color(0xFF5CAE97),
    'Garage': Color(0xFFC4936B),
    'Jets': Color(0xFF8B7BC2),
    'Yachts': Color(0xFF55A4B5),
    'Others': Color(0xFFB5708E),
  };
}
