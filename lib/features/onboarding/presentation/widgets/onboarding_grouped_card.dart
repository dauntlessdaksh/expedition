import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Grouped card container for premium onboarding form sections.
class OnboardingGroupedCard extends StatelessWidget {
  const OnboardingGroupedCard({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: AppColorPalette.darkCardElevated.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

/// Tappable row inside a grouped card.
class OnboardingGroupedRow extends StatelessWidget {
  const OnboardingGroupedRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.radiusXl,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColorPalette.primary.withValues(alpha: 0.12),
                  borderRadius: AppBorderRadius.radiusMd,
                ),
                child: Icon(
                  icon,
                  color: AppColorPalette.primaryLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColorPalette.grey300,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColorPalette.grey500.withValues(alpha: 0.8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
