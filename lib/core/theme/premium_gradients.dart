import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Premium gradient presets used across onboarding screens.
abstract final class PremiumGradients {
  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorPalette.darkBackground,
      AppColorPalette.gradientMid,
      AppColorPalette.darkBackground,
    ],
  );

  static const LinearGradient heroGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x000D9488),
      Color(0x400D9488),
      Color(0x000D9488),
    ],
  );

  static const LinearGradient accentButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColorPalette.primary,
      AppColorPalette.primaryLight,
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

  static LinearGradient avatarRing(Color accent) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent,
          AppColorPalette.primaryLight,
          AppColorPalette.accent,
        ],
      );
}
