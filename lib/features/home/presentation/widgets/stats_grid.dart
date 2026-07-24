import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/home_dashboard_data.dart';

/// A single stat tile used inside [StatsGrid].
class StatTile extends StatelessWidget {
  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    this.highlight = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: PremiumGradients.cardShimmer,
            borderRadius: AppBorderRadius.radiusXxl,
            border: Border.all(
              color: highlight
                  ? AppColorPalette.primary.withValues(alpha: 0.35)
                  : AppColorPalette.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: highlight
                    ? AppColorPalette.primary
                    : AppColorPalette.textSecondary,
                size: 22,
              ),
              const Spacer(),
              Text(
                label.toUpperCase(),
                style: AppTypography.statLabel,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.statMedium.copyWith(
                  fontSize: 22,
                  color: highlight
                      ? AppColorPalette.primary
                      : AppColorPalette.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: animatedProgress,
                  minHeight: 3,
                  backgroundColor: AppColorPalette.surface,
                  color: AppColorPalette.primary,
                ),
              ),
            ],
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

/// 2×2 grid of quick daily stat cards.
class StatsGrid extends StatelessWidget {
  const StatsGrid({
    required this.stats,
    super.key,
  });

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.1,
      children: [
        StatTile(
          icon: Icons.local_fire_department_rounded,
          label: 'Calories',
          value: '${stats.calories} kcal',
          progress: stats.caloriesProgress,
        ),
        StatTile(
          icon: Icons.directions_walk_rounded,
          label: 'Steps',
          value: _formatNumber(stats.steps),
          progress: stats.stepsProgress,
          highlight: true,
        ),
        StatTile(
          icon: Icons.straighten_rounded,
          label: 'Distance',
          value: '${stats.distanceKm.toStringAsFixed(1)} km',
          progress: stats.distanceProgress,
        ),
        StatTile(
          icon: Icons.timer_rounded,
          label: 'Active Min',
          value: '${stats.activeMinutes} min',
          progress: stats.activeMinutesProgress,
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
