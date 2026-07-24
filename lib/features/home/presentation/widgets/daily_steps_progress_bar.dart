import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Premium animated daily step goal progress.
class DailyStepsProgressBar extends StatelessWidget {
  const DailyStepsProgressBar({
    required this.stats,
    super.key,
  });

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;
    final progress = stats.stepsProgress.clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'Daily Steps',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: percent),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Text(
                  '$value%',
                  style: const TextStyle(
                    color: AppColorPalette.primaryLight,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: stats.steps),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, steps, _) {
                return Text(
                  _formatNumber(steps),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            Text(
              ' / ${_formatNumber(stats.stepsGoal)} steps',
              style: TextStyle(
                color: colors.textSecondary.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1300),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, _) {
                final barWidth = constraints.maxWidth;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: colors.progressTrack,
                        border: Border.all(
                          color: colors.divider,
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: animatedProgress.clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: PremiumGradients.accentButton,
                          boxShadow: [
                            BoxShadow(
                              color: AppColorPalette.primary.withValues(
                                alpha: 0.55,
                              ),
                              blurRadius: 14,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (animatedProgress > 0.02)
                      Positioned(
                        left: barWidth * animatedProgress - 6,
                        top: -1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: PremiumGradients.accentButton,
                            boxShadow: [
                              BoxShadow(
                                color: AppColorPalette.primary.withValues(
                                  alpha: 0.8,
                                ),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: colors.textPrimary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
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
