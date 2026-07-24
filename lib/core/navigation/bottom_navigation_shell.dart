import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../services/haptic_service.dart';
import 'bottom_navigation_bar.dart';
import 'main_navigation.dart';
import 'shell_tab_index_scope.dart';

/// Hosts the indexed tab stack and persistent floating bottom navigation.
class BottomNavigationShell extends StatelessWidget {
  const BottomNavigationShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final showBottomNav = MainNavigation.shouldShowBottomNav(location);

    return ShellTabIndexScope(
      currentIndex: navigationShell.currentIndex,
      child: Scaffold(
        backgroundColor: AppColorPalette.darkBackground,
        extendBody: showBottomNav,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: showBottomNav ? MainNavigation.bottomNavReservedHeight : 0,
              ),
              child: navigationShell,
            ),
            if (showBottomNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ExpeditionBottomNavigationBar(
                  currentIndex: navigationShell.currentIndex,
                  onTabSelected: (index) {
                    if (index != navigationShell.currentIndex) {
                      HapticService.tabChanged();
                    }
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
