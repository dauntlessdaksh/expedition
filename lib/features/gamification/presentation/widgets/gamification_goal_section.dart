import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/goal.dart';
import 'gamification_section_card.dart';

/// Goal progress bars synced from workout data.
class GamificationGoalSection extends StatelessWidget {
  const GamificationGoalSection({
    required this.goals,
    super.key,
  });

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return GamificationSectionCard(
      title: 'Goals',
      subtitle: 'Automatically updated from your workouts',
      child: Column(
        children: goals.map((goal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _GoalCard(goal: goal),
          );
        }).toList(),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: AppColorPalette.grey700.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${goal.progressPercent}%',
                style: const TextStyle(
                  color: AppColorPalette.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GamificationProgressBar(progress: goal.progress),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_formatValue(goal.currentValue)} / ${_formatValue(goal.targetValue)}',
            style: const TextStyle(
              color: AppColorPalette.grey500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (goal.id.contains('distance')) {
      return '${value.toStringAsFixed(1)} km';
    }
    if (goal.id.contains('minutes')) {
      return '${value.round()} min';
    }
    if (goal.id.contains('steps')) {
      return value.round().toString();
    }
    return value.round().toString();
  }
}
