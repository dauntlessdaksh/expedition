import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../../../history/domain/models/workout.dart';
import '../../../shared/utils/workout_display_formatters.dart';

/// Premium card for the most recent workout session.
class RecentWorkoutCard extends StatelessWidget {
  const RecentWorkoutCard({
    this.workout,
    super.key,
  });

  final Workout? workout;

  @override
  Widget build(BuildContext context) {
    if (workout == null) {
      return const _EmptyRecentWorkout();
    }

    final activityLabel =
        WorkoutDisplayFormatters.activityType(workout!.activityType);
    final distance =
        WorkoutDisplayFormatters.distanceMeters(workout!.distanceInMeters);
    final duration =
        WorkoutDisplayFormatters.durationSeconds(workout!.durationInSeconds);
    final pace = WorkoutDisplayFormatters.speedMps(workout!.averageSpeed);
    final dateLabel =
        WorkoutDisplayFormatters.workoutDateShort(workout!.startTime);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: workout!.id == null
            ? null
            : () => context.push(RouteConstants.historyDetailPath(workout!.id!)),
        borderRadius: AppBorderRadius.radiusXxl,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColorPalette.black.withValues(alpha: 0.45),
            borderRadius: AppBorderRadius.radiusXxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Workout',
                style: TextStyle(
                  color: AppColorPalette.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                activityLabel,
                style: const TextStyle(
                  color: AppColorPalette.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: AppColorPalette.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _MetricBlock(
                      label: 'Distance',
                      value: distance,
                    ),
                  ),
                  Expanded(
                    child: _MetricBlock(
                      label: 'Duration',
                      value: duration,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _MetricBlock(
                      label: 'Calories',
                      value: '${workout!.calories}',
                    ),
                  ),
                  Expanded(
                    child: _MetricBlock(
                      label: 'Avg Pace',
                      value: pace,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColorPalette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: const TextStyle(
            color: AppColorPalette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _EmptyRecentWorkout extends StatelessWidget {
  const _EmptyRecentWorkout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColorPalette.black.withValues(alpha: 0.35),
        borderRadius: AppBorderRadius.radiusXxl,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Workout',
            style: TextStyle(
              color: AppColorPalette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No workouts yet',
            style: TextStyle(
              color: AppColorPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Complete an activity to see it here.',
            style: TextStyle(
              color: AppColorPalette.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
