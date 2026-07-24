import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/main_tab.dart';
import '../../../../core/navigation/shell_tab_index_scope.dart';
import '../bloc/activity_bloc.dart';

/// Starts/stops activity location preview based on shell tab visibility.
///
/// Prevents Google Maps from initializing while the Home avatar WebView is
/// active — a common source of Android platform-view conflicts.
class ActivityTabScope extends StatefulWidget {
  const ActivityTabScope({
    required this.child,
    super.key,
  });

  final Widget child;

  static bool isTabActive(BuildContext context) {
    return ShellTabIndexScope.indexOf(context) ==
        MainTab.activity.branchIndex;
  }

  @override
  State<ActivityTabScope> createState() => _ActivityTabScopeState();
}

class _ActivityTabScopeState extends State<ActivityTabScope> {
  bool _previewActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPreview();
  }

  void _syncPreview() {
    final isActive = ActivityTabScope.isTabActive(context);
    final bloc = context.read<ActivityBloc>();

    if (isActive) {
      if (!_previewActive) {
        bloc.add(const ActivityStarted());
        _previewActive = true;
      }
      return;
    }

    if (_previewActive) {
      bloc.add(const ActivityPreviewStopped());
      _previewActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActivityTabActiveScope(
      isActive: ActivityTabScope.isTabActive(context),
      child: widget.child,
    );
  }
}

/// Whether the Activity tab is currently selected in the shell.
class ActivityTabActiveScope extends InheritedWidget {
  const ActivityTabActiveScope({
    required this.isActive,
    required super.child,
    super.key,
  });

  final bool isActive;

  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ActivityTabActiveScope>()
            ?.isActive ??
        false;
  }

  @override
  bool updateShouldNotify(ActivityTabActiveScope oldWidget) {
    return oldWidget.isActive != isActive;
  }
}
