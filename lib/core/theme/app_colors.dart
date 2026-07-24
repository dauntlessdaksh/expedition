import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic color roles for light and dark themes.
abstract final class AppColors {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColorPalette.primary,
    onPrimary: AppColorPalette.white,
    primaryContainer: AppColorPalette.primaryLight,
    onPrimaryContainer: AppColorPalette.primaryDark,
    secondary: AppColorPalette.accent,
    onSecondary: AppColorPalette.white,
    secondaryContainer: AppColorPalette.lightCardElevated,
    onSecondaryContainer: AppColorPalette.lightTextPrimary,
    tertiary: AppColorPalette.lightTextSecondary,
    onTertiary: AppColorPalette.white,
    error: AppColorPalette.error,
    onError: AppColorPalette.white,
    surface: AppColorPalette.lightBackground,
    onSurface: AppColorPalette.lightTextPrimary,
    onSurfaceVariant: AppColorPalette.lightTextSecondary,
    outline: AppColorPalette.grey400,
    outlineVariant: Color(0x1A111827),
    shadow: AppColorPalette.black,
    scrim: AppColorPalette.black,
    inverseSurface: AppColorPalette.lightTextPrimary,
    onInverseSurface: AppColorPalette.lightBackground,
    inversePrimary: AppColorPalette.primaryLight,
    surfaceTint: AppColorPalette.primary,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorPalette.primary,
    onPrimary: AppColorPalette.white,
    primaryContainer: AppColorPalette.primaryDark,
    onPrimaryContainer: AppColorPalette.primaryLight,
    secondary: AppColorPalette.accentLight,
    onSecondary: AppColorPalette.white,
    secondaryContainer: AppColorPalette.darkCard,
    onSecondaryContainer: AppColorPalette.textPrimary,
    tertiary: AppColorPalette.textSecondary,
    onTertiary: AppColorPalette.white,
    error: AppColorPalette.error,
    onError: AppColorPalette.white,
    surface: AppColorPalette.darkBackground,
    onSurface: AppColorPalette.textPrimary,
    onSurfaceVariant: AppColorPalette.textSecondary,
    outline: AppColorPalette.grey600,
    outlineVariant: AppColorPalette.divider,
    shadow: AppColorPalette.black,
    scrim: AppColorPalette.black,
    inverseSurface: AppColorPalette.textPrimary,
    onInverseSurface: AppColorPalette.darkBackground,
    inversePrimary: AppColorPalette.primaryLight,
    surfaceTint: AppColorPalette.primary,
  );
}
