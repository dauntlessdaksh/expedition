import 'package:flutter/material.dart';

/// Raw color palette for Expedition — dark monochrome with performance red.
abstract final class AppColorPalette {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0B0C10);
  static const Color darkSurface = Color(0xFF111318);
  static const Color surface = Color(0xFF171A21);
  static const Color darkCard = Color(0xFF1D212A);
  static const Color darkCardElevated = Color(0xFF252932);

  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFE8EAEE);

  // ── Accent (performance red) ───────────────────────────────────────────
  static const Color primary = Color(0xFFE53935);
  static const Color primaryLight = Color(0xFFFF5252);
  static const Color primaryDark = Color(0xFFC62828);

  static const Color accent = Color(0xFFE53935);
  static const Color accentLight = Color(0xFFFF5252);
  static const Color accentDark = Color(0xFFC62828);
  static const Color accentGradientStart = Color(0xFFFF3B30);
  static const Color accentGradientEnd = Color(0xFFC62828);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF5A5F69);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFFF5F5F5);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color disabled = Color(0xFF5A5F69);

  // ── Dividers & overlays ────────────────────────────────────────────────
  static const Color divider = Color(0x0DFFFFFF);
  static const Color glassOverlay = Color(0xCC1D212A);

  // ── Route polyline gradient stops ────────────────────────────────────────
  static const Color routeGreen = Color(0xFF2ECC71);
  static const Color routeYellow = Color(0xFFFFC107);
  static const Color routeOrange = Color(0xFFFF9800);
  static const Color routeRed = Color(0xFFE53935);

  // ── Legacy gradient aliases ──────────────────────────────────────────────
  static const Color gradientStart = darkBackground;
  static const Color gradientMid = darkSurface;
  static const Color gradientEnd = primaryDark;
}
