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

  static const _stepsFill = AppColorPalette.primaryDark;
  static const _stepsTrack = Color(0x66C62828);

  static const _distanceFill = Color(0xFF5FA300);
  static const _distanceTrack = Color(0x665FA300);

  static const _caloriesFill = Color(0xFFE65100);
  static const _caloriesTrack = Color(0x66E65100);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

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
            isLight: isLight,
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
    required this.isLight,
  });

  final double stepsProgress;
  final double distanceProgress;
  final double caloriesProgress;
  final bool compact;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = compact ? 10.0 : 11.0;
    final gap = compact ? 6.0 : 7.0;
    final ringPitch = strokeWidth + gap;

    final outerRadius = size.width / 2 - strokeWidth / 2;
    final middleRadius = outerRadius - ringPitch;
    final innerRadius = middleRadius - ringPitch;

    _drawRing(
      canvas: canvas,
      center: center,
      radius: outerRadius,
      progress: stepsProgress,
      fillColor: DailyGoalRings._stepsFill,
      trackColor: DailyGoalRings._stepsTrack,
      strokeWidth: strokeWidth,
      isLight: isLight,
    );

    _drawRing(
      canvas: canvas,
      center: center,
      radius: middleRadius,
      progress: distanceProgress,
      fillColor: DailyGoalRings._distanceFill,
      trackColor: DailyGoalRings._distanceTrack,
      strokeWidth: strokeWidth,
      isLight: isLight,
    );

    _drawRing(
      canvas: canvas,
      center: center,
      radius: innerRadius,
      progress: caloriesProgress,
      fillColor: DailyGoalRings._caloriesFill,
      trackColor: DailyGoalRings._caloriesTrack,
      strokeWidth: strokeWidth,
      isLight: isLight,
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double progress,
    required Color fillColor,
    required Color trackColor,
    required double strokeWidth,
    required bool isLight,
  }) {
    if (radius <= 0) {
      return;
    }

    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: isLight ? 0.42 : 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = fillColor
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
        oldDelegate.compact != compact ||
        oldDelegate.isLight != isLight;
  }
}
