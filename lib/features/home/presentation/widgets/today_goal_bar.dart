import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Animated horizontal progress toward today's primary goal.
class TodayGoalBar extends StatelessWidget {
  const TodayGoalBar({
    required this.stats,
    super.key,
  });

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    final progress = stats.primaryProgress.clamp(0.0, 1.0);
    final percent = stats.primaryProgressPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Goal",
              style: TextStyle(
                color: AppColorPalette.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Text(
                  '$value%',
                  style: const TextStyle(
                    color: AppColorPalette.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: AppColorPalette.grey800.withValues(alpha: 0.85),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: const ColoredBox(
                        color: AppColorPalette.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
