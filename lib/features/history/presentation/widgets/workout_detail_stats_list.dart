import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/workout_analytics.dart';
import '../../../shared/utils/workout_display_formatters.dart';
import 'workout_detail_widgets.dart';

/// Premium 2×3 stat grid for workout detail (reference layout).
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
    final paceSeconds = WorkoutAnalytics.averagePaceSecondsPerKm(
      distanceMeters: workout.distanceInMeters,
      durationSeconds: workout.durationInSeconds,
    );

    final stats = <_GridStatData>[
      _GridStatData(
        icon: Icons.schedule_rounded,
        iconColor: AppColorPalette.primary,
        label: 'Duration',
        value: WorkoutDisplayFormatters.durationSeconds(
          workout.durationInSeconds,
        ),
      ),
      _GridStatData(
        icon: Icons.route_rounded,
        iconColor: const Color(0xFF60A5FA),
        label: 'Distance',
        value: WorkoutDisplayFormatters.distanceMeters(
          workout.distanceInMeters,
        ),
      ),
      _GridStatData(
        icon: Icons.speed_rounded,
        iconColor: const Color(0xFF4ADE80),
        label: 'Avg Pace',
        value: WorkoutAnalytics.formatPaceShort(paceSeconds),
      ),
      _GridStatData(
        icon: Icons.directions_run_rounded,
        iconColor: const Color(0xFF38BDF8),
        label: 'Avg Speed',
        value: WorkoutDisplayFormatters.speedMps(workout.averageSpeed),
      ),
      _GridStatData(
        icon: Icons.terrain_rounded,
        iconColor: const Color(0xFFA78BFA),
        label: 'Elevation',
        value: WorkoutDisplayFormatters.elevationDeltaMeters(
          workout.elevationGainMeters,
        ),
      ),
      _GridStatData(
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFB923C),
        label: 'Calories',
        value: '${workout.calories} kcal',
      ),
    ];

    return WorkoutDetailFadeSlide(
      delayMs: animationOffset * 45,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          return _StatGridCard(data: stats[index]);
        },
      ),
    );
  }
}

class _GridStatData {
  const _GridStatData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
}

class _StatGridCard extends StatelessWidget {
  const _StatGridCard({required this.data});

  final _GridStatData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: 0.94),
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: colors.cardElevated.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.iconColor, size: 22),
          const Spacer(),
          AnimatedStatValue(
            value: data.value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            data.label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
