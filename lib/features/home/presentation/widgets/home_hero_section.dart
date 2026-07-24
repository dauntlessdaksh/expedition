import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/avatar_layout.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../domain/models/home_dashboard_data.dart';
import 'avatar_card.dart';
import 'daily_goal_rings.dart';

/// Two-column hero matching the reference layout: avatar left, rings + stats right.
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    required this.stats,
    super.key,
  });

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 58,
            child: AvatarCard(
              key: avatarLayoutKey,
              compact: true,
              fillHeight: true,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 42,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 136,
                  width: 136,
                  child: DailyGoalRings(stats: stats, compact: true),
                ),
                const SizedBox(height: AppSpacing.xl),
                _RingMetrics(stats: stats),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingMetrics extends StatelessWidget {
  const _RingMetrics({required this.stats});

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(
          icon: Icons.directions_walk_rounded,
          iconColor: AppColorPalette.primary,
          value: _formatNumber(stats.steps),
          label: 'Steps',
        ),
        const SizedBox(height: AppSpacing.lg),
        _MetricRow(
          icon: Icons.navigation_rounded,
          iconColor: const Color(0xFFA6FF00),
          value: '${stats.distanceKm.toStringAsFixed(1)} km',
          label: 'Distance',
        ),
        const SizedBox(height: AppSpacing.lg),
        _MetricRow(
          icon: Icons.local_fire_department_rounded,
          iconColor: AppColorPalette.routeOrange,
          value: '${stats.calories}',
          label: 'Calories',
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

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 30,
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                height: 1.05,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
