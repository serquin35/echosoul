import 'package:flutter/material.dart';
import '../constants/es_colors.dart';
import '../constants/es_typography.dart';

abstract class AppTheme {
  // ── Dark Theme (primary) ───────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: EsColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: EsColors.primaryBlue,
          secondary: EsColors.neonCyan,
          surface: EsColors.surfaceDark,
          error: EsColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: EsColors.textPrimaryDark,
          onError: Colors.white,
        ),
        textTheme: _buildTextTheme(dark: true),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: EsColors.primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: EsTypography.labelLarge,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: EsColors.neonCyan,
            side: const BorderSide(color: EsColors.neonCyan),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: EsColors.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: EsColors.primaryBlue, width: 2),
          ),
          labelStyle: EsTypography.bodyMedium,
          hintStyle: EsTypography.bodyMedium,
        ),
        cardTheme: CardThemeData(
          color: EsColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: EsColors.divider,
          thickness: 1,
        ),
        fontFamily: EsTypography.fontFamily,
      );

  // ── Light Theme (secondary) ────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: EsColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: EsColors.primaryBlue,
          secondary: EsColors.deepBlue,
          surface: EsColors.surfaceLight,
          error: EsColors.error,
          onPrimary: Colors.white,
          onSurface: EsColors.textPrimaryLight,
        ),
        textTheme: _buildTextTheme(dark: false),
        fontFamily: EsTypography.fontFamily,
      );

  static TextTheme _buildTextTheme({required bool dark}) {
    final base = dark ? EsColors.textPrimaryDark : EsColors.textPrimaryLight;
    final secondary = dark ? EsColors.textSecondaryDark : EsColors.textSecondaryLight;
    return TextTheme(
      displayLarge: EsTypography.displayLarge.copyWith(color: base),
      displayMedium: EsTypography.displayMedium.copyWith(color: base),
      headlineLarge: EsTypography.headlineLarge.copyWith(color: base),
      headlineMedium: EsTypography.headlineMedium.copyWith(color: base),
      bodyLarge: EsTypography.bodyLarge.copyWith(color: base),
      bodyMedium: EsTypography.bodyMedium.copyWith(color: secondary),
      labelLarge: EsTypography.labelLarge.copyWith(color: base),
      bodySmall: EsTypography.caption.copyWith(color: secondary),
    );
  }
}
