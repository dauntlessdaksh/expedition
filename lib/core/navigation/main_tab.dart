import 'package:flutter/material.dart';

import '../router/route_constants.dart';

/// Primary destinations in the app's bottom navigation shell.
///
/// Order: Home → Activity → Analytics → History
enum MainTab {
  home(
    branchIndex: 0,
    path: RouteConstants.home,
    label: 'Home',
    icon: Icons.home_rounded,
  ),
  activity(
    branchIndex: 1,
    path: RouteConstants.activity,
    label: 'Activity',
    icon: Icons.directions_run_rounded,
  ),
  analytics(
    branchIndex: 2,
    path: RouteConstants.analytics,
    label: 'Analytics',
    icon: Icons.insights_rounded,
  ),
  history(
    branchIndex: 3,
    path: RouteConstants.history,
    label: 'History',
    icon: Icons.history_rounded,
  );

  const MainTab({
    required this.branchIndex,
    required this.path,
    required this.label,
    required this.icon,
  });

  final int branchIndex;
  final String path;
  final String label;
  final IconData icon;

  static MainTab fromBranchIndex(int index) {
    return MainTab.values.firstWhere((tab) => tab.branchIndex == index);
  }

  static MainTab? fromLocation(String location) {
    if (location.startsWith(RouteConstants.history)) {
      return MainTab.history;
    }
    if (location.startsWith(RouteConstants.activity)) {
      return MainTab.activity;
    }
    if (location.startsWith(RouteConstants.analytics)) {
      return MainTab.analytics;
    }
    if (location.startsWith(RouteConstants.home)) {
      return MainTab.home;
    }
    return null;
  }
}
