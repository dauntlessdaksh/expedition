import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/analytics_summary.dart';
import 'analytics_animated_value.dart';

/// Four animated summary cards for lifetime workout totals.
class AnalyticsSummaryCards extends StatelessWidget {
  const AnalyticsSummaryCards({
    required this.summary,
    super.key,
  });

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.35,
      children: [
        AnalyticsSummaryTile(
          label: 'Total Distance',
          value: summary.totalDistanceKm,
          formatter: (value) => '${value.toStringAsFixed(1)} km',
        ),
        AnalyticsSummaryTile(
          label: 'Total Workouts',
          value: summary.totalWorkouts,
          formatter: (value) => value.round().toString(),
        ),
        AnalyticsSummaryTile(
          label: 'Total Active Time',
          value: summary.totalActiveMinutes,
          formatter: _formatMinutes,
        ),
        AnalyticsSummaryTile(
          label: 'Total Calories',
          value: summary.totalCalories,
          formatter: (value) => '${value.round()} kcal',
        ),
      ],
    );
  }

  static String _formatMinutes(num minutes) {
    final totalMinutes = minutes.round();
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }

    final hours = totalMinutes ~/ 60;
    final remainder = totalMinutes % 60;
    if (remainder == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainder}m';
  }
}
