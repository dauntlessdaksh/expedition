import '../router/route_constants.dart';

/// Primary destinations in the app's bottom navigation shell.
enum MainTab {
  home(
    branchIndex: 0,
    path: RouteConstants.home,
    label: 'Home',
  ),
  activity(
    branchIndex: 1,
    path: RouteConstants.activity,
    label: 'Activities',
  ),
  history(
    branchIndex: 2,
    path: RouteConstants.history,
    label: 'History',
  ),
  analytics(
    branchIndex: 3,
    path: RouteConstants.analytics,
    label: 'Analytics',
  );

  const MainTab({
    required this.branchIndex,
    required this.path,
    required this.label,
  });

  final int branchIndex;
  final String path;
  final String label;

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
