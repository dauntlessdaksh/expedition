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

/// Elevated card with soft shadow and rounded corners.
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
    final borderColor = isSelected
        ? (selectedColor ?? AppColorPalette.primary)
        : AppColorPalette.darkCardElevated.withValues(alpha: 0.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColorPalette.primary.withValues(alpha: 0.2)
                : AppColorPalette.black.withValues(alpha: 0.3),
            blurRadius: isSelected ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.radiusLg,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
