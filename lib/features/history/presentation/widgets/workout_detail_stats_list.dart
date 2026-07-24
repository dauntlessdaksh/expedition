import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/workout_analytics.dart';
import '../../../shared/utils/workout_display_formatters.dart';
import 'workout_detail_widgets.dart';

/// Compact premium stat rows for workout detail.
class WorkoutDetailStatsList extends StatelessWidget {
  const WorkoutDetailStatsList({
    required this.workout,
    required this.animationOffset,
    super.key,
  });

  final Workout workout;
  final int animationOffset;

  @override
  Widget build(BuildContext context) {
    final paceSeconds = workout.movingTimeInSeconds > 0
        ? WorkoutAnalytics.averagePaceSecondsPerKm(
            distanceMeters: workout.distanceInMeters,
            durationSeconds: workout.movingTimeInSeconds,
          )
        : WorkoutAnalytics.averagePaceSecondsPerKm(
            distanceMeters: workout.distanceInMeters,
            durationSeconds: workout.durationInSeconds,
          );

    final rows = <_StatRowData>[
      _StatRowData(Icons.schedule_rounded, 'Duration',
          WorkoutDisplayFormatters.durationSeconds(workout.durationInSeconds)),
      _StatRowData(Icons.straighten_rounded, 'Distance',
          WorkoutDisplayFormatters.distanceMeters(workout.distanceInMeters)),
      _StatRowData(Icons.speed_rounded, 'Average Pace',
          WorkoutAnalytics.formatPace(paceSeconds)),
      _StatRowData(Icons.directions_run_rounded, 'Average Speed',
          WorkoutDisplayFormatters.speedMps(workout.averageSpeed)),
      _StatRowData(Icons.local_fire_department_rounded, 'Calories',
          '${workout.calories} kcal'),
      _StatRowData(Icons.terrain_rounded, 'Elevation Gain',
          WorkoutDisplayFormatters.elevationDeltaMeters(
              workout.elevationGainMeters)),
      _StatRowData(Icons.trending_down_rounded, 'Elevation Loss',
          WorkoutDisplayFormatters.elevationChangeMeters(
              workout.elevationLossMeters)),
      _StatRowData(Icons.arrow_upward_rounded, 'Highest Elevation',
          WorkoutDisplayFormatters.elevationMeters(
              workout.highestElevationMeters)),
      _StatRowData(Icons.arrow_downward_rounded, 'Lowest Elevation',
          WorkoutDisplayFormatters.elevationMeters(
              workout.lowestElevationMeters)),
      _StatRowData(Icons.favorite_outline_rounded, 'Average Heart Rate', '—'),
      _StatRowData(Icons.flash_on_rounded, 'Maximum Speed',
          WorkoutDisplayFormatters.speedMps(workout.maxSpeed)),
      _StatRowData(Icons.timer_outlined, 'Moving Time',
          WorkoutDisplayFormatters.durationSeconds(workout.movingTimeInSeconds)),
      _StatRowData(Icons.hourglass_empty_rounded, 'Elapsed Time',
          WorkoutDisplayFormatters.durationSeconds(workout.durationInSeconds)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard.withValues(alpha: 0.72),
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            WorkoutDetailFadeSlide(
              delayMs: (animationOffset + i) * 45,
              child: _StatRow(
                data: rows[i],
                showDivider: i != rows.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatRowData {
  const _StatRowData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.data,
    required this.showDivider,
  });

  final _StatRowData data;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColorPalette.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  data.icon,
                  color: AppColorPalette.primaryLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  data.label,
                  style: const TextStyle(
                    color: AppColorPalette.grey400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AnimatedStatValue(
                value: data.value,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: AppColorPalette.darkCardElevated.withValues(alpha: 0.65),
          ),
      ],
    );
  }
}
