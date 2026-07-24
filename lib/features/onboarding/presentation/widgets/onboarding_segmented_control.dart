import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../data/models/activity_level.dart';

/// Premium segmented control for activity level selection.
class OnboardingSegmentedControl extends StatelessWidget {
  const OnboardingSegmentedControl({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ActivityLevel? selected;
  final ValueChanged<ActivityLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard,
        borderRadius: AppBorderRadius.radiusFull,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: ActivityLevel.values.map((level) {
          final isSelected = selected == level;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: _SegmentOption(
              label: level.label,
              isSelected: isSelected,
              onTap: () => onChanged(level),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isSelected ? PremiumGradients.accentButton : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: AppBorderRadius.radiusFull,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColorPalette.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.radiusFull,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColorPalette.white
                      : AppColorPalette.grey400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
