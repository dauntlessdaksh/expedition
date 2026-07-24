import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/home_dashboard_data.dart';

/// A single stat tile used inside [StatsGrid].
class StatTile extends StatelessWidget {
  const StatTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.progress,
    super.key,
  });

  final String emoji;
  final String label;
  final String value;
  final double progress;

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
            borderRadius: AppBorderRadius.radiusLg,
            border: Border.all(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  color: AppColorPalette.grey400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: animatedProgress,
                  minHeight: 3,
                  backgroundColor: AppColorPalette.darkCardElevated,
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
      childAspectRatio: 1.15,
      children: [
        StatTile(
          emoji: '🔥',
          label: 'Calories',
          value: '${stats.calories} kcal',
          progress: stats.caloriesProgress,
        ),
        StatTile(
          emoji: '👣',
          label: 'Steps',
          value: _formatNumber(stats.steps),
          progress: stats.stepsProgress,
        ),
        StatTile(
          emoji: '📏',
          label: 'Distance',
          value: '${stats.distanceKm.toStringAsFixed(1)} km',
          progress: stats.distanceProgress,
        ),
        StatTile(
          emoji: '⏱',
          label: 'Active Minutes',
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
