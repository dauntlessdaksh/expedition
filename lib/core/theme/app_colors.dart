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
    secondaryContainer: AppColorPalette.accentLight,
    onSecondaryContainer: AppColorPalette.accentDark,
    tertiary: AppColorPalette.info,
    onTertiary: AppColorPalette.white,
    error: AppColorPalette.error,
    onError: AppColorPalette.white,
    surface: AppColorPalette.white,
    onSurface: AppColorPalette.grey900,
    onSurfaceVariant: AppColorPalette.grey600,
    outline: AppColorPalette.grey300,
    outlineVariant: AppColorPalette.grey200,
    shadow: AppColorPalette.black,
    scrim: AppColorPalette.black,
    inverseSurface: AppColorPalette.grey900,
    onInverseSurface: AppColorPalette.grey100,
    inversePrimary: AppColorPalette.primaryLight,
    surfaceTint: AppColorPalette.primary,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorPalette.primaryLight,
    onPrimary: AppColorPalette.grey900,
    primaryContainer: AppColorPalette.primaryDark,
    onPrimaryContainer: AppColorPalette.primaryLight,
    secondary: AppColorPalette.accent,
    onSecondary: AppColorPalette.grey900,
    secondaryContainer: AppColorPalette.accentDark,
    onSecondaryContainer: AppColorPalette.accentLight,
    tertiary: AppColorPalette.info,
    onTertiary: AppColorPalette.white,
    error: AppColorPalette.error,
    onError: AppColorPalette.white,
    surface: AppColorPalette.grey900,
    onSurface: AppColorPalette.grey100,
    onSurfaceVariant: AppColorPalette.grey400,
    outline: AppColorPalette.grey600,
    outlineVariant: AppColorPalette.grey700,
    shadow: AppColorPalette.black,
    scrim: AppColorPalette.black,
    inverseSurface: AppColorPalette.grey100,
    onInverseSurface: AppColorPalette.grey900,
    inversePrimary: AppColorPalette.primary,
    surfaceTint: AppColorPalette.primaryLight,
  );
}
