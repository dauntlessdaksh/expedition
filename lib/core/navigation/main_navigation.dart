import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/haptic_service.dart';
import 'main_tab.dart';

/// Navigation helpers for the main bottom navigation shell.
abstract final class MainNavigation {
  static const double bottomNavReservedHeight = 96;

  static bool shouldShowBottomNav(String location) {
    final detailPattern = RegExp(r'^/history/\d+');
    if (detailPattern.hasMatch(location)) {
      return false;
    }
    if (location.contains('/profile') || location.contains('/gamification')) {
      return false;
    }
    return true;
  }

  static void goToTab(BuildContext context, MainTab tab) {
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      if (shell.currentIndex != tab.branchIndex) {
        HapticService.tabChanged();
      }
      shell.goBranch(
        tab.branchIndex,
        initialLocation: tab.branchIndex == shell.currentIndex,
      );
      return;
    }

    HapticService.tabChanged();
    context.go(tab.path);
  }

  static void goToPath(BuildContext context, String path) {
    context.go(path);
  }
}
