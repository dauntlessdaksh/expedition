import 'package:flutter/material.dart';

/// Raw color palette used across the Expedition application.
abstract final class AppColorPalette {
  // Primary — emerald green for a premium fitness feel
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);

  // Accent — warm coral for highlights and CTAs
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8A5C);
  static const Color accentDark = Color(0xFFE55A2B);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Premium dark surfaces
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF14141F);
  static const Color darkCard = Color(0xFF1C1C2E);
  static const Color darkCardElevated = Color(0xFF242438);

  // Premium gradients
  static const Color gradientStart = Color(0xFF0A0A0F);
  static const Color gradientMid = Color(0xFF141428);
  static const Color gradientEnd = Color(0xFF10B981);
}
