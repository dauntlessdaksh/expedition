import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Horizontal card highlighting the user's current activity streak.
class StreakCard extends StatelessWidget {
  const StreakCard({
    required this.streakDays,
    super.key,
  });

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardAccentEdge,
        borderRadius: AppBorderRadius.radiusXxl,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColorPalette.primary.withValues(alpha: 0.15),
              borderRadius: AppBorderRadius.radiusXl,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColorPalette.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays Day Streak',
                  style: const TextStyle(
                    color: AppColorPalette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "You've been active for $streakDays consecutive days.",
                  style: const TextStyle(
                    color: AppColorPalette.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
