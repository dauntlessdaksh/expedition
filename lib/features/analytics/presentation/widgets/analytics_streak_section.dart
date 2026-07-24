import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/analytics_records.dart';
import 'analytics_animated_value.dart';
import 'analytics_section_card.dart';

/// Displays current streak, longest streak, and total active days.
class AnalyticsStreakSection extends StatelessWidget {
  const AnalyticsStreakSection({
    required this.streakStats,
    super.key,
  });

  final StreakStats streakStats;

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Current Streak',
      subtitle: 'Consistency builds momentum',
      child: Row(
        children: [
          Expanded(
            child: _StreakTile(
              label: 'Current Streak',
              value: streakStats.currentStreak,
              suffix: 'days',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StreakTile(
              label: 'Longest Streak',
              value: streakStats.longestStreak,
              suffix: 'days',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StreakTile(
              label: 'Active Days',
              value: streakStats.totalActiveDays,
              suffix: 'total',
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmerFor(context),
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnalyticsAnimatedValue(
            value: value,
            formatter: (animatedValue) => animatedValue.round().toString(),
            style: const TextStyle(
              color: AppColorPalette.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            suffix,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
