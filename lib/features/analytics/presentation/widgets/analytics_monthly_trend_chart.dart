import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/analytics_chart_models.dart';
import '../../domain/models/monthly_trend_range.dart';
import 'analytics_section_card.dart';

/// Smooth distance trend line chart with selectable time ranges.
class AnalyticsMonthlyTrendChart extends StatefulWidget {
  const AnalyticsMonthlyTrendChart({
    required this.monthlyTrends,
    super.key,
  });

  final Map<MonthlyTrendRange, List<AnalyticsTrendPoint>> monthlyTrends;

  @override
  State<AnalyticsMonthlyTrendChart> createState() =>
      _AnalyticsMonthlyTrendChartState();
}

class _AnalyticsMonthlyTrendChartState extends State<AnalyticsMonthlyTrendChart> {
  MonthlyTrendRange _selectedRange = MonthlyTrendRange.last30Days;

  @override
  Widget build(BuildContext context) {
    final points = widget.monthlyTrends[_selectedRange] ?? const [];
    final maxDistance = points.fold<double>(
      0,
      (max, point) => point.distanceKm > max ? point.distanceKm : max,
    );
    final chartMaxY = maxDistance <= 0 ? 1.0 : maxDistance * 1.15;

    return AnalyticsSectionCard(
      title: 'Monthly Trend',
      subtitle: 'Workout distance over time',
      trailing: _RangeSelector(
        selectedRange: _selectedRange,
        onChanged: (range) => setState(() => _selectedRange = range),
      ),
      child: SizedBox(
        height: 240,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: points.isEmpty ? 1 : (points.length - 1).toDouble(),
            minY: 0,
            maxY: chartMaxY,
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
                  reservedSize: 28,
                  interval: _bottomLabelInterval(points.length),
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      DateFormat('MMM d').format(points[index].date),
                      style: const TextStyle(
                        color: AppColorPalette.grey500,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(points.length, (index) {
                  return FlSpot(index.toDouble(), points[index].distanceKm);
                }),
                isCurved: true,
                curveSmoothness: 0.28,
                color: AppColorPalette.primaryLight,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColorPalette.primary.withValues(alpha: 0.28),
                      AppColorPalette.primary.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  double _bottomLabelInterval(int pointCount) {
    if (pointCount <= 7) {
      return 1;
    }
    if (pointCount <= 30) {
      return 5;
    }
    if (pointCount <= 90) {
      return 14;
    }
    return 30;
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selectedRange,
    required this.onChanged,
  });

  final MonthlyTrendRange selectedRange;
  final ValueChanged<MonthlyTrendRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: MonthlyTrendRange.values.map((range) {
        final isSelected = range == selectedRange;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(range),
            borderRadius: AppBorderRadius.radiusMd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColorPalette.primary.withValues(alpha: 0.2)
                    : AppColorPalette.darkCardElevated,
                borderRadius: AppBorderRadius.radiusMd,
                border: Border.all(
                  color: isSelected
                      ? AppColorPalette.primary.withValues(alpha: 0.5)
                      : AppColorPalette.grey700.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                range.label,
                style: TextStyle(
                  color: isSelected
                      ? AppColorPalette.primaryLight
                      : AppColorPalette.grey400,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
