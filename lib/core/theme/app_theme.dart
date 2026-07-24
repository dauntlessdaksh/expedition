import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_border_radius.dart';
import '../constants/app_colors.dart';
import 'app_colors.dart' as theme_colors;
import 'app_typography.dart';
import 'expedition_colors.dart';

/// Central theme configuration for the Expedition application.
abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
        colorScheme: theme_colors.AppColors.lightColorScheme,
        brightness: Brightness.light,
        expeditionColors: ExpeditionColors.light,
      );

  static ThemeData get dark => _buildTheme(
        colorScheme: theme_colors.AppColors.darkColorScheme,
        brightness: Brightness.dark,
        expeditionColors: ExpeditionColors.dark,
      );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required ExpeditionColors expeditionColors,
  }) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [expeditionColors],
      textTheme: AppTypography.textTheme(brightness),
      scaffoldBackgroundColor: expeditionColors.scaffoldBackground,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: expeditionColors.textPrimary,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: isLight ? 1 : 0,
        shadowColor: AppColorPalette.black.withValues(alpha: 0.08),
        color: expeditionColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusXl,
          side: BorderSide(color: expeditionColors.divider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: AppColorPalette.primary,
          foregroundColor: AppColorPalette.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.radiusFull,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          foregroundColor: expeditionColors.textPrimary,
          side: BorderSide(
            color: expeditionColors.divider,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.radiusFull,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColorPalette.primary,
        foregroundColor: AppColorPalette.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: expeditionColors.cardElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: BorderSide(color: expeditionColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: BorderSide(color: expeditionColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: const BorderSide(color: AppColorPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: const BorderSide(color: AppColorPalette.error),
        ),
        labelStyle: TextStyle(color: expeditionColors.textSecondary),
        hintStyle: TextStyle(
          color: expeditionColors.textMuted.withValues(alpha: 0.9),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: expeditionColors.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: expeditionColors.card,
        contentTextStyle: TextStyle(color: expeditionColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusXl,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColorPalette.primary,
        linearTrackColor: expeditionColors.progressTrack,
        circularTrackColor: expeditionColors.progressTrack,
      ),
      iconTheme: IconThemeData(
        color: expeditionColors.textPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColorPalette.primary,
        unselectedItemColor: expeditionColors.textMuted,
      ),
    );
  }
}
