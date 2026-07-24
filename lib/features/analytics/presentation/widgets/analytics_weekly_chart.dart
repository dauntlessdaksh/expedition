import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/analytics_chart_models.dart';
import 'analytics_section_card.dart';

/// Weekly distance bar chart powered by fl_chart.
class AnalyticsWeeklyChart extends StatelessWidget {
  const AnalyticsWeeklyChart({
    required this.weeklyActivity,
    super.key,
  });

  final List<AnalyticsWeeklyDay> weeklyActivity;

  @override
  Widget build(BuildContext context) {
    final maxDistance = weeklyActivity.fold<double>(
      0,
      (max, day) => day.distanceKm > max ? day.distanceKm : max,
    );
    final chartMaxY = maxDistance <= 0 ? 1.0 : maxDistance * 1.2;

    return AnalyticsSectionCard(
      title: 'Weekly Activity',
      subtitle: 'Distance covered each day this week',
      child: RepaintBoundary(
        child: SizedBox(
          height: 220,
        child: BarChart(
          BarChartData(
            maxY: chartMaxY,
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: chartMaxY / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  interval: chartMaxY / 4,
                  getTitlesWidget: (value, _) {
                    if (value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColorPalette.grey500,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= weeklyActivity.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        weeklyActivity[index].label,
                        style: const TextStyle(
                          color: AppColorPalette.grey500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(weeklyActivity.length, (index) {
              final day = weeklyActivity[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: day.distanceKm,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColorPalette.primary,
                        AppColorPalette.primaryLight,
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
        ),
        ),
      ),
    );
  }
}
