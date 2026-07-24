import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

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
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColorPalette.primary.withValues(alpha: 0.18),
            AppColorPalette.darkCard,
          ],
        ),
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primary.withValues(alpha: 0.1),
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
              borderRadius: AppBorderRadius.radiusMd,
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 26)),
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
                    color: AppColorPalette.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "You've been active for $streakDays consecutive days.",
                  style: const TextStyle(
                    color: AppColorPalette.grey400,
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
