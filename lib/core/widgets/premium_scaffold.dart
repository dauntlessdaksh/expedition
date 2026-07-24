import 'package:flutter/material.dart';

import '../constants/app_border_radius.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../theme/premium_gradients.dart';

/// Scaffold with a premium gradient background for onboarding flows.
class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.gradient = PremiumGradients.darkBackground,
    this.safeArea = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Gradient gradient;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPalette.darkBackground,
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: safeArea ? SafeArea(child: body) : body,
      ),
    );
  }
}

/// Elevated dark card with soft shadow and glass-like border.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final accent = selectedColor ?? AppColorPalette.primary;
    final borderColor = isSelected ? accent : AppColorPalette.divider;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXxl,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? accent.withValues(alpha: 0.22)
                : AppColorPalette.black.withValues(alpha: 0.35),
            blurRadius: isSelected ? 24 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.radiusXxl,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
