import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/workout.dart';
import '../../../../core/widgets/highlighted_text.dart';
import '../../../shared/utils/workout_display_formatters.dart';

/// Premium list tile for a saved workout in history.
class WorkoutHistoryCard extends StatelessWidget {
  const WorkoutHistoryCard({
    required this.workout,
    required this.onTap,
    this.searchQuery = '',
    super.key,
  });

  final Workout workout;
  final VoidCallback onTap;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final activityLabel =
        WorkoutDisplayFormatters.activityType(workout.activityType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.radiusXl,
        child: Ink(
          decoration: BoxDecoration(
            gradient: PremiumGradients.cardShimmer,
            borderRadius: AppBorderRadius.radiusXxl,
            border: Border.all(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Hero(
                  tag: 'workout-icon-${workout.id}',
                  child: _ActivityIcon(activityType: workout.activityType),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'workout-title-${workout.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: HighlightedText(
                            text: activityLabel,
                            query: searchQuery,
                            style: const TextStyle(
                              color: AppColorPalette.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        WorkoutDisplayFormatters.workoutDate(workout.startTime),
                        style: const TextStyle(
                          color: AppColorPalette.grey500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _MetricChip(
                            icon: Icons.timer_outlined,
                            label: WorkoutDisplayFormatters.durationSeconds(
                              workout.durationInSeconds,
                            ),
                          ),
                          _MetricChip(
                            icon: Icons.straighten_rounded,
                            label: WorkoutDisplayFormatters.distanceMeters(
                              workout.distanceInMeters,
                            ),
                          ),
                          _MetricChip(
                            icon: Icons.local_fire_department_outlined,
                            label: '${workout.calories} kcal',
                          ),
                          _MetricChip(
                            icon: Icons.speed_rounded,
                            label: WorkoutDisplayFormatters.speedMps(
                              workout.averageSpeed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColorPalette.grey500,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({required this.activityType});

  final String activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorPalette.primary.withValues(alpha: 0.25),
            AppColorPalette.darkCardElevated,
          ],
        ),
        borderRadius: AppBorderRadius.radiusMd,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(
        _iconForType(activityType),
        color: AppColorPalette.primaryLight,
        size: 24,
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type.contains('run')) {
      return Icons.directions_run_rounded;
    }
    if (type.contains('walk')) {
      return Icons.directions_walk_rounded;
    }
    if (type.contains('cycle') || type.contains('bike')) {
      return Icons.directions_bike_rounded;
    }
    return Icons.fitness_center_rounded;
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColorPalette.grey400),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            color: AppColorPalette.grey300,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
