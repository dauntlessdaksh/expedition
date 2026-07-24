import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
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
    final colors = context.expeditionColors;
    final maxDistance = weeklyActivity.fold<double>(
      0,
      (max, day) => day.distanceKm > max ? day.distanceKm : max,
    );
    final chartMaxY = maxDistance <= 0
        ? 1.0
        : _niceInterval(maxDistance * 1.2) * 4;
    final yInterval = _niceInterval(chartMaxY);

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
              horizontalInterval: yInterval,
              getDrawingHorizontalLine: (_) => FlLine(
                color: colors.chartGrid.withValues(alpha: 0.8),
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
                  interval: yInterval,
                  getTitlesWidget: (value, _) {
                    if (value <= 0) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        color: colors.textMuted,
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
                        style: TextStyle(
                          color: colors.textMuted,
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

  static double _niceInterval(double maxY) {
    if (maxY <= 0) return 1;
    final raw = maxY / 4;
    final magnitude = _pow10(raw.floor().toString().length - 1);
    final normalized = raw / magnitude;
    final nice = normalized <= 1
        ? 1
        : normalized <= 2
            ? 2
            : normalized <= 5
                ? 5
                : 10;
    return nice * magnitude;
  }

  static double _pow10(int exponent) {
    var value = 1.0;
    for (var i = 0; i < exponent; i++) {
      value *= 10;
    }
    return value;
  }
}
