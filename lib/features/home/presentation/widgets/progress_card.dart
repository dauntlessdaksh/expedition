import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Large animated progress ring with today's key metrics.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.stats,
    super.key,
  });

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXxl,
        border: Border.all(color: AppColorPalette.divider),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S GOAL",
            style: AppTypography.statLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            "Today's Progress",
            style: TextStyle(
              color: AppColorPalette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              SizedBox(
                width: 128,
                height: 128,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: stats.primaryProgress),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomPaint(
                      painter: _ProgressRingPainter(progress: value),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(value * 100).round()}%',
                              style: AppTypography.statMedium.copyWith(
                                fontSize: 28,
                                color: AppColorPalette.primary,
                              ),
                            ),
                            const Text(
                              'STEPS',
                              style: AppTypography.statLabel,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricRow(
                      label: 'Steps',
                      value:
                          '${_formatNumber(stats.steps)} / ${_formatNumber(stats.stepsGoal)}',
                      emphasized: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MetricRow(
                      label: 'Calories',
                      value: '${stats.calories} kcal',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MetricRow(
                      label: 'Distance',
                      value: '${stats.distanceKm.toStringAsFixed(1)} km',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MetricRow(
                      label: 'Active Minutes',
                      value: '${stats.activeMinutes} min',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.statLabel.copyWith(letterSpacing: 0.4),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasized
                ? AppColorPalette.textPrimary
                : AppColorPalette.textSecondary,
            fontSize: emphasized ? 15 : 13,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    final backgroundPaint = Paint()
      ..color = AppColorPalette.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          AppColorPalette.accentGradientStart,
          AppColorPalette.primary,
          AppColorPalette.accentGradientEnd,
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
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
