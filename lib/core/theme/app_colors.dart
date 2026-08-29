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

  // ── Dark Palette ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0E1621);
  static const Color darkCard = Color(0xFF172331);
  static const Color darkAccent = Color(0xFF5E8BB8);
  static const Color darkTextPrimary = Color(0xFFF0F5FA);
  static const Color darkTextMuted = Color(0xFF6B8299);

  // Neumorphic shadows (dark theme)
  static const Color darkShadowDark = Color(0xFF090F18);
  static const Color darkShadowLight = Color(0xFF1F3347);

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFE05B5B);
  static const Color success = Color(0xFF5BB8A0);

  // ── Category Colors ────────────────────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'Home': Color(0xFF7B9EC2),
    'Places': Color(0xFF6DB29A),
    'Garage': Color(0xFFB2896D),
    'Jets': Color(0xFF8B7BC2),
    'Yachts': Color(0xFF6BA8B2),
    'Others': Color(0xFFB27B9A),
  };
}
