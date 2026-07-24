import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Typography styles for the Expedition application.
abstract final class AppTypography {
  static const String _fontFamily = 'Roboto';

  static TextTheme textTheme(Brightness brightness) {
    const baseColor = AppColorPalette.textPrimary;
    const mutedColor = AppColorPalette.textSecondary;

    return TextTheme(
      displayLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: baseColor,
        height: 1.05,
      ),
      displayMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: baseColor,
        height: 1.08,
      ),
      displaySmall: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: baseColor,
        height: 1.1,
      ),
      headlineLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: baseColor,
      ),
      headlineMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: baseColor,
      ),
      headlineSmall: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: baseColor,
      ),
      titleLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: baseColor,
      ),
      titleSmall: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: baseColor,
      ),
      bodyLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: baseColor,
      ),
      bodyMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: mutedColor,
      ),
      bodySmall: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: mutedColor,
      ),
      labelLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: mutedColor,
      ),
      labelMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: mutedColor,
      ),
      labelSmall: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: mutedColor,
      ),
    );
  }

  /// Large performance statistic — e.g. "7.95 km", "52 min".
  static const TextStyle statLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColorPalette.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1,
  );

  /// Medium performance statistic for cards and grids.
  static const TextStyle statMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColorPalette.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Subtle label beneath statistics.
  static const TextStyle statLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
    color: AppColorPalette.textSecondary,
  );
}
