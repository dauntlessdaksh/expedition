import 'package:flutter/material.dart';

/// Exposes the active [StatefulNavigationShell] tab index to shell branches.
class ShellTabIndexScope extends InheritedWidget {
  const ShellTabIndexScope({
    required this.currentIndex,
    required super.child,
    super.key,
  });

  final int currentIndex;

  static ShellTabIndexScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellTabIndexScope>();
  }

  static int indexOf(BuildContext context) {
    return maybeOf(context)?.currentIndex ?? 0;
  }

  @override
  bool updateShouldNotify(ShellTabIndexScope oldWidget) {
    return oldWidget.currentIndex != currentIndex;
  }
}
