import 'package:flutter/services.dart';

/// Centralized haptic feedback for premium interactions.
abstract final class HapticService {
  static void lightImpact() => HapticFeedback.lightImpact();

  static void mediumImpact() => HapticFeedback.mediumImpact();

  static void heavyImpact() => HapticFeedback.heavyImpact();

  static void selection() => HapticFeedback.selectionClick();

  static void workoutStarted() => mediumImpact();

  static void workoutCompleted() => heavyImpact();

  static void achievementUnlocked() {
    heavyImpact();
    Future<void>.delayed(const Duration(milliseconds: 120), lightImpact);
  }

  static void deleteConfirmed() => heavyImpact();

  static void navigationTap() => mediumImpact();

  static void tabChanged() {
    mediumImpact();
    Future<void>.delayed(const Duration(milliseconds: 40), selection);
  }
}
