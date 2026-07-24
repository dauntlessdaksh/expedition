import 'package:flutter/material.dart';

/// Ensures interactive elements meet minimum touch target guidelines.
class MinTouchTarget extends StatelessWidget {
  const MinTouchTarget({
    required this.child,
    this.minSize = 48,
    super.key,
  });

  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: Center(child: child),
    );
  }
}
