import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Apple Watch–style concentric activity rings.
class DailyGoalRings extends StatelessWidget {
  const DailyGoalRings({
    required this.stats,
    this.compact = false,
    super.key,
  });

  final DailyStats stats;
  final bool compact;

  static const _moveColor = AppColorPalette.primary;
  static const _exerciseColor = Color(0xFFA6FF00);
  static const _standColor = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, _) {
        return CustomPaint(
          painter: _ActivityRingsPainter(
            stepsProgress:
                stats.stepsProgress.clamp(0.0, 1.0) * animationValue,
            distanceProgress:
                stats.distanceProgress.clamp(0.0, 1.0) * animationValue,
            caloriesProgress:
                stats.caloriesProgress.clamp(0.0, 1.0) * animationValue,
            compact: compact,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ActivityRingsPainter extends CustomPainter {
  const _ActivityRingsPainter({
    required this.stepsProgress,
    required this.distanceProgress,
    required this.caloriesProgress,
    required this.compact,
  });

  final double stepsProgress;
  final double distanceProgress;
  final double caloriesProgress;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = compact ? 10.0 : 11.0;
    final gap = compact ? 6.0 : 7.0;

    _drawRing(
      canvas: canvas,
      center: center,
      radius: size.width / 2 - strokeWidth / 2,
      progress: stepsProgress,
      color: DailyGoalRings._moveColor,
      strokeWidth: strokeWidth,
    );

    _drawRing(
      canvas: canvas,
      center: center,
      radius: size.width / 2 - strokeWidth - gap,
      progress: distanceProgress,
      color: DailyGoalRings._exerciseColor,
      strokeWidth: strokeWidth,
    );

    _drawRing(
      canvas: canvas,
      center: center,
      radius: size.width / 2 - (strokeWidth + gap) * 2,
      progress: caloriesProgress,
      color: DailyGoalRings._standColor,
      strokeWidth: strokeWidth,
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double progress,
    required Color color,
    required double strokeWidth,
  }) {
    if (radius <= 0) {
      return;
    }

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityRingsPainter oldDelegate) {
    return oldDelegate.stepsProgress != stepsProgress ||
        oldDelegate.distanceProgress != distanceProgress ||
        oldDelegate.caloriesProgress != caloriesProgress ||
        oldDelegate.compact != compact;
  }
}
