import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_border_radius.dart';
import '../constants/app_colors.dart';
import 'app_colors.dart' as theme_colors;
import 'app_typography.dart';

/// Central theme configuration for the Expedition application.
abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
        colorScheme: theme_colors.AppColors.lightColorScheme,
        brightness: Brightness.dark,
      );

  static ThemeData get dark => _buildTheme(
        colorScheme: theme_colors.AppColors.darkColorScheme,
        brightness: Brightness.dark,
      );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme(brightness),
      scaffoldBackgroundColor: AppColorPalette.darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColorPalette.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColorPalette.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusXl,
          side: const BorderSide(color: AppColorPalette.divider),
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
          foregroundColor: AppColorPalette.textPrimary,
          side: BorderSide(
            color: AppColorPalette.grey600.withValues(alpha: 0.6),
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
        fillColor: AppColorPalette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: const BorderSide(color: AppColorPalette.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: const BorderSide(color: AppColorPalette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: const BorderSide(color: AppColorPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusXl,
          borderSide: const BorderSide(color: AppColorPalette.error),
        ),
        labelStyle: const TextStyle(color: AppColorPalette.textSecondary),
        hintStyle: const TextStyle(color: AppColorPalette.disabled),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorPalette.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColorPalette.darkCard,
        contentTextStyle: const TextStyle(color: AppColorPalette.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusXl,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorPalette.primary,
        linearTrackColor: AppColorPalette.surface,
        circularTrackColor: AppColorPalette.surface,
      ),
      iconTheme: const IconThemeData(
        color: AppColorPalette.textPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColorPalette.primary,
        unselectedItemColor: AppColorPalette.disabled,
      ),
    );
  }
}
