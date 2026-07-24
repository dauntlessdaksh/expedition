import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Premium vertical metrics — large icon, number, and label per stat.
class DailyMetricsColumn extends StatelessWidget {
  const DailyMetricsColumn({
    required this.stats,
    super.key,
  });

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MetricColumn(
            icon: Icons.directions_walk_rounded,
            iconColor: AppColorPalette.primary,
            value: _formatNumber(stats.steps),
            label: 'Steps',
          ),
        ),
        Expanded(
          child: _MetricColumn(
            icon: Icons.place_rounded,
            iconColor: AppColorPalette.success,
            value: stats.distanceKm.toStringAsFixed(1),
            valueSuffix: ' km',
            label: 'Distance',
          ),
        ),
        Expanded(
          child: _MetricColumn(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColorPalette.routeOrange,
            value: '${stats.calories}',
            label: 'Calories',
          ),
        ),
      ],
    );
  }

  static String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueSuffix = '',
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String valueSuffix;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 32,
        ),
        const SizedBox(height: AppSpacing.md),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: AppColorPalette.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
              height: 1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            children: [
              TextSpan(text: value),
              if (valueSuffix.isNotEmpty)
                TextSpan(
                  text: valueSuffix,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColorPalette.textPrimary.withValues(alpha: 0.85),
                    letterSpacing: -0.4,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            color: AppColorPalette.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
