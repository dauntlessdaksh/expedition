import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic surface and text colors that adapt per brightness.
@immutable
class ExpeditionColors extends ThemeExtension<ExpeditionColors> {
  const ExpeditionColors({
    required this.scaffoldBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.card,
    required this.cardElevated,
    required this.divider,
    required this.progressTrack,
    required this.glassNavBackground,
    required this.glassNavBorder,
    required this.inactiveNavIcon,
    required this.chartGrid,
  });

  final Color scaffoldBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color card;
  final Color cardElevated;
  final Color divider;
  final Color progressTrack;
  final Color glassNavBackground;
  final Color glassNavBorder;
  final Color inactiveNavIcon;
  final Color chartGrid;

  static const ExpeditionColors light = ExpeditionColors(
    scaffoldBackground: AppColorPalette.lightSurface,
    textPrimary: AppColorPalette.lightTextPrimary,
    textSecondary: AppColorPalette.lightTextSecondary,
    textMuted: AppColorPalette.grey600,
    card: AppColorPalette.lightCard,
    cardElevated: AppColorPalette.lightCardElevated,
    divider: Color(0xFFE5E7EB),
    progressTrack: AppColorPalette.grey200,
    glassNavBackground: Color(0xF5FFFFFF),
    glassNavBorder: Color(0x1A111827),
    inactiveNavIcon: AppColorPalette.grey500,
    chartGrid: AppColorPalette.grey300,
  );

  static const ExpeditionColors dark = ExpeditionColors(
    scaffoldBackground: AppColorPalette.darkBackground,
    textPrimary: AppColorPalette.textPrimary,
    textSecondary: AppColorPalette.textSecondary,
    textMuted: AppColorPalette.disabled,
    card: AppColorPalette.darkCard,
    cardElevated: AppColorPalette.darkCardElevated,
    divider: AppColorPalette.divider,
    progressTrack: AppColorPalette.surface,
    glassNavBackground: Color(0xB80F0F12),
    glassNavBorder: Color(0x14FFFFFF),
    inactiveNavIcon: AppColorPalette.disabled,
    chartGrid: AppColorPalette.grey700,
  );

  @override
  ExpeditionColors copyWith({
    Color? scaffoldBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? card,
    Color? cardElevated,
    Color? divider,
    Color? progressTrack,
    Color? glassNavBackground,
    Color? glassNavBorder,
    Color? inactiveNavIcon,
    Color? chartGrid,
  }) {
    return ExpeditionColors(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      card: card ?? this.card,
      cardElevated: cardElevated ?? this.cardElevated,
      divider: divider ?? this.divider,
      progressTrack: progressTrack ?? this.progressTrack,
      glassNavBackground: glassNavBackground ?? this.glassNavBackground,
      glassNavBorder: glassNavBorder ?? this.glassNavBorder,
      inactiveNavIcon: inactiveNavIcon ?? this.inactiveNavIcon,
      chartGrid: chartGrid ?? this.chartGrid,
    );
  }

  @override
  ExpeditionColors lerp(ThemeExtension<ExpeditionColors>? other, double t) {
    if (other is! ExpeditionColors) return this;

    return ExpeditionColors(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      glassNavBackground:
          Color.lerp(glassNavBackground, other.glassNavBackground, t)!,
      glassNavBorder: Color.lerp(glassNavBorder, other.glassNavBorder, t)!,
      inactiveNavIcon: Color.lerp(inactiveNavIcon, other.inactiveNavIcon, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
    );
  }
}

extension ExpeditionColorsContext on BuildContext {
  ExpeditionColors get expeditionColors =>
      Theme.of(this).extension<ExpeditionColors>() ?? ExpeditionColors.dark;
}
