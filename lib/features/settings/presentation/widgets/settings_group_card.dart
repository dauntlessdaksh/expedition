import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';

/// Grouped settings card matching the premium reference layout.
class SettingsGroupCard extends StatelessWidget {
  const SettingsGroupCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: colors.cardElevated.withValues(alpha: 0.7),
        ),
      ),
      child: child,
    );
  }
}

/// Tappable picker row with icon, label, and accent value.
class SettingsPickerRow extends StatelessWidget {
  const SettingsPickerRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Column(
      children: [
        Material(
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
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColorPalette.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.unfold_more_rounded,
                    color: AppColorPalette.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: colors.cardElevated.withValues(alpha: 0.8),
          ),
      ],
    );
  }
}

/// Section label above grouped cards.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Helper text below a settings section.
class SettingsSectionHint extends StatelessWidget {
  const SettingsSectionHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xl,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}
