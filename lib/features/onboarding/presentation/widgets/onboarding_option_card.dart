import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Selectable card used for gender, goals, and activity level choices.
class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.subtitle,
    this.icon,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: isSelected
              ? AppColorPalette.primary
              : AppColorPalette.darkCardElevated.withValues(alpha: 0.6),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColorPalette.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.radiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                if (leading != null)
                  leading!
                else if (icon != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColorPalette.primary.withValues(alpha: 0.15)
                          : AppColorPalette.darkCardElevated,
                      borderRadius: AppBorderRadius.radiusMd,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppColorPalette.primaryLight
                          : AppColorPalette.grey400,
                    ),
                  ),
                if (icon != null || leading != null)
                  const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected
                              ? AppColorPalette.white
                              : AppColorPalette.grey200,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColorPalette.grey400,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColorPalette.primary
                          : AppColorPalette.grey600,
                      width: 2,
                    ),
                    color: isSelected
                        ? AppColorPalette.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColorPalette.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gender-specific leading icon for gender selection cards.
class GenderLeadingIcon extends StatelessWidget {
  const GenderLeadingIcon({
    required this.icon,
    required this.isSelected,
    super.key,
  });

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: isSelected
            ? PremiumGradients.accentButton
            : PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusMd,
      ),
      child: Icon(
        icon,
        color: isSelected
            ? AppColorPalette.white
            : AppColorPalette.grey400,
        size: 28,
      ),
    );
  }
}
