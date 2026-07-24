import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/analytics_records.dart';
import 'analytics_section_card.dart';

/// Circular progress cards for weekly and monthly goals.
class AnalyticsGoalProgress extends StatelessWidget {
  const AnalyticsGoalProgress({
    required this.goals,
    super.key,
  });

  final List<GoalProgressItem> goals;

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Goal Progress',
      subtitle: 'Track momentum toward your targets',
      child: Row(
        children: goals.map((goal) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: goal == goals.last ? 0 : AppSpacing.sm,
              ),
              child: _GoalRing(goal: goal),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.goal});

  final GoalProgressItem goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: goal.clampedProgress),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) {
                return CustomPaint(
                  painter: _GoalRingPainter(progress: progress),
                  child: Center(
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: AppColorPalette.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            goal.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            goal.valueLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Goal ${goal.goalLabel}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColorPalette.grey500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  const _GoalRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 7.0;

    final backgroundPaint = Paint()
      ..color = AppColorPalette.darkCardElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          AppColorPalette.primary,
          AppColorPalette.primaryLight,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoalRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
