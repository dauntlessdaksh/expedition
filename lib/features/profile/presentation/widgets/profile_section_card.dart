import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Shared rounded card wrapper for profile sections.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColorPalette.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColorPalette.grey500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

/// Tappable profile field row with trailing value.
class ProfileFieldTile extends StatelessWidget {
  const ProfileFieldTile({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
            borderRadius: AppBorderRadius.radiusLg,
            border: Border.all(
              color: AppColorPalette.grey700.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColorPalette.grey400,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColorPalette.grey500,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented choice row for profile preference options.
class ProfileChoiceRow extends StatelessWidget {
  const ProfileChoiceRow({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    super.key,
  });

  final List<ProfileChoiceOption> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = option.value == selectedValue;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(option.value),
            borderRadius: AppBorderRadius.radiusMd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColorPalette.primary.withValues(alpha: 0.18)
                    : AppColorPalette.darkCardElevated,
                borderRadius: AppBorderRadius.radiusMd,
                border: Border.all(
                  color: isSelected
                      ? AppColorPalette.primary.withValues(alpha: 0.5)
                      : AppColorPalette.grey700.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected
                      ? AppColorPalette.primaryLight
                      : AppColorPalette.grey400,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ProfileChoiceOption {
  const ProfileChoiceOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

/// Action button used in data management and about sections.
class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? AppColorPalette.error : AppColorPalette.primaryLight;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.45)),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.radiusLg,
          ),
        ),
      ),
    );
  }
}
