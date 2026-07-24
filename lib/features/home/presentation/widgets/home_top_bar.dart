import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';

/// Top bar with greeting and settings for the home screen.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    required this.userName,
    required this.onSettingsTap,
    super.key,
  });

  final String userName;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey,',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          _TopIconButton(
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
            semanticLabel: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: colors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
