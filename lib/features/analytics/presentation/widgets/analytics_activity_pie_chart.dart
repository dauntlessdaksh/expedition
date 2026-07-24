import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../domain/models/analytics_chart_models.dart';
import 'analytics_section_card.dart';

/// Activity distribution pie chart with category legend.
class AnalyticsActivityPieChart extends StatelessWidget {
  const AnalyticsActivityPieChart({
    required this.distribution,
    super.key,
  });

  final ActivityDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;
    final sections = _buildSections();

    return AnalyticsSectionCard(
      title: 'Activity Distribution',
      subtitle: 'Workout mix by activity type',
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: sections.isEmpty
                ? Center(
                    child: Text(
                      'No activity data yet',
                      style: TextStyle(color: colors.textMuted),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 52,
                      sections: sections,
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _LegendItem(
                color: AppColorPalette.primaryLight,
                label: 'Walking',
              ),
              _LegendItem(
                color: AppColorPalette.primary,
                label: 'Running',
              ),
              _LegendItem(
                color: AppColorPalette.primaryDark,
                label: 'Cycling',
              ),
              _LegendItem(
                color: AppColorPalette.grey600,
                label: 'Other',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final entries = <({String label, double percent, Color color})>[
      (
        label: 'Walking',
        percent: distribution.walkingPercent,
        color: AppColorPalette.primaryLight,
      ),
      (
        label: 'Running',
        percent: distribution.runningPercent,
        color: AppColorPalette.primary,
      ),
      (
        label: 'Cycling',
        percent: distribution.cyclingPercent,
        color: AppColorPalette.primaryDark,
      ),
      (
        label: 'Other',
        percent: distribution.otherPercent,
        color: AppColorPalette.grey600,
      ),
    ];

    return entries
        .where((entry) => entry.percent > 0)
        .map(
          (entry) => PieChartSectionData(
            value: entry.percent,
            color: entry.color,
            radius: 72,
            title: '${entry.percent.round()}%',
            titleStyle: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
        .toList();
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
