// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightAccent,
        secondary: AppColors.lightAccent,
        surface: AppColors.lightCard,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.lightTextPrimary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightCard,
        modalBackgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        AppColors.lightCard,
        AppColors.lightTextPrimary,
        AppColors.lightTextMuted,
      ),
      extensions: const [
        AppThemeExtension(
          bgColor: AppColors.lightBackground,
          cardColor: AppColors.lightCard,
          accent: AppColors.lightAccent,
          textPrimary: AppColors.lightTextPrimary,
          textMuted: AppColors.lightTextMuted,
          shadowDark: AppColors.lightShadowDark,
          shadowLight: AppColors.lightShadowLight,
        ),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkAccent,
        secondary: AppColors.darkAccent,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        modalBackgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        AppColors.darkCard,
        AppColors.darkTextPrimary,
        AppColors.darkTextMuted,
      ),
      extensions: const [
        AppThemeExtension(
          bgColor: AppColors.darkBackground,
          cardColor: AppColors.darkCard,
          accent: AppColors.darkAccent,
          textPrimary: AppColors.darkTextPrimary,
          textMuted: AppColors.darkTextMuted,
          shadowDark: AppColors.darkShadowDark,
          shadowLight: AppColors.darkShadowLight,
        ),
      ],
    );
  }

  static TextTheme _textTheme(Color primary, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: primary),
      bodyMedium: TextStyle(fontSize: 13, color: muted),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.8,
      ),
    );
  }

  static InputDecorationTheme _inputTheme(
    Color fill,
    Color text,
    Color hint,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.lightAccent.withValues(alpha: 0.4), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}

// ── Theme Extension ────────────────────────────────────────────────────────────

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color bgColor;
  final Color cardColor;
  final Color accent;
  final Color textPrimary;
  final Color textMuted;
  final Color shadowDark;
  final Color shadowLight;

  const AppThemeExtension({
    required this.bgColor,
    required this.cardColor,
    required this.accent,
    required this.textPrimary,
    required this.textMuted,
    required this.shadowDark,
    required this.shadowLight,
  });

  @override
  AppThemeExtension copyWith({
    Color? bgColor,
    Color? cardColor,
    Color? accent,
    Color? textPrimary,
    Color? textMuted,
    Color? shadowDark,
    Color? shadowLight,
  }) {
    return AppThemeExtension(
      bgColor: bgColor ?? this.bgColor,
      cardColor: cardColor ?? this.cardColor,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      shadowDark: shadowDark ?? this.shadowDark,
      shadowLight: shadowLight ?? this.shadowLight,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      bgColor: Color.lerp(bgColor, other.bgColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
    );
  }
}

extension ThemeX on BuildContext {
  AppThemeExtension get ext =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
