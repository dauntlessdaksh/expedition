import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Premium gradient presets for Expedition's athletic UI.
abstract final class PremiumGradients {
  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColorPalette.darkBackground,
      AppColorPalette.darkSurface,
      AppColorPalette.darkBackground,
    ],
  );

  static const LinearGradient heroGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00E53935),
      Color(0x26E53935),
      Color(0x00E53935),
    ],
  );

  static const LinearGradient accentButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorPalette.accentGradientStart,
      AppColorPalette.accentGradientEnd,
    ],
  );

  static const LinearGradient cardShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorPalette.darkCard,
      AppColorPalette.darkCardElevated,
    ],
  );

  static const LinearGradient lightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColorPalette.lightBackground,
      AppColorPalette.lightSurface,
      AppColorPalette.lightBackground,
    ],
  );

  static const LinearGradient lightCardShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorPalette.lightCard,
      AppColorPalette.lightCardElevated,
    ],
  );

  static LinearGradient scaffoldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightBackground
        : darkBackground;
  }

  static LinearGradient cardShimmerFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightCardShimmer
        : cardShimmer;
  }

  static const LinearGradient cardAccentEdge = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x33E53935),
      AppColorPalette.darkCard,
    ],
  );

  static const LinearGradient progressRing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorPalette.accentGradientStart,
      AppColorPalette.primary,
      AppColorPalette.accentGradientEnd,
    ],
  );

  static const LinearGradient chartBar = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      AppColorPalette.primaryDark,
      AppColorPalette.primaryLight,
    ],
  );

  static LinearGradient avatarRing(Color accent) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent,
          AppColorPalette.primaryLight,
          AppColorPalette.accentGradientEnd,
        ],
      );

  static const List<Color> routeGradient = [
    AppColorPalette.routeGreen,
    AppColorPalette.routeYellow,
    AppColorPalette.routeOrange,
    AppColorPalette.routeRed,
  ];
}
