import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Premium hourly step chart with gradient bars and glow effects.
class HourlyActivityGraph extends StatefulWidget {
  const HourlyActivityGraph({
    required this.hourlyActivity,
    required this.totalSteps,
    super.key,
  });

  final HourlyActivityData hourlyActivity;
  final int totalSteps;

  @override
  State<HourlyActivityGraph> createState() => _HourlyActivityGraphState();
}

class _HourlyActivityGraphState extends State<HourlyActivityGraph> {
  int? _selectedHour;
  Timer? _clockTimer;

  int get _currentHour => DateTime.now().hour;

  int get _activeHour {
    if (_selectedHour != null) {
      return _selectedHour!;
    }

    final values = widget.hourlyActivity.stepsByHour;

    if (values[_currentHour] > 0) {
      return _currentHour;
    }

    var peakHour = _currentHour;
    var peakValue = 0.0;
    for (var hour = 0; hour < 24; hour++) {
      if (values[hour] > peakValue) {
        peakValue = values[hour];
        peakHour = hour;
      }
    }

    return peakValue > 0 ? peakHour : _currentHour;
  }

  int get _displayedSteps =>
      widget.hourlyActivity.stepsByHour[_activeHour].round();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted || _selectedHour != null) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant HourlyActivityGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hourlyActivity != widget.hourlyActivity ||
        oldWidget.totalSteps != widget.totalSteps) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.hourlyActivity.stepsByHour;
    final maxValue = values.fold<double>(0, (a, b) => a > b ? a : b);
    final normalization = maxValue > 0 ? maxValue : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<int>(
            key: ValueKey('steps-$_activeHour-$_displayedSteps'),
            tween: IntTween(begin: 0, end: _displayedSteps),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            builder: (context, animatedSteps, _) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return PremiumGradients.accentButton.createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Text(
                  '${_formatNumber(animatedSteps)} STEPS',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: RadialGradient(
                  center: const Alignment(0, 0.6),
                  radius: 1.1,
                  colors: [
                    AppColorPalette.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: AppColorPalette.white.withValues(alpha: 0.04),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Expanded(
                          child: CustomPaint(
                            painter: _HourlyChartPainter(
                              activeHour: _activeHour,
                              currentHour: _currentHour,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(24, (hour) {
                                final normalized =
                                    values[hour] / normalization;
                                final isSelected = hour == _activeHour;
                                final isCurrent = hour == _currentHour;
                                final hasActivity = values[hour] > 0;

                                return Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() {
                                        _selectedHour =
                                            _selectedHour == hour ? null : hour;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1.2,
                                      ),
                                      child: TweenAnimationBuilder<double>(
                                        key: ValueKey('bar-$hour'),
                                        tween: Tween(begin: 0, end: normalized),
                                        duration: Duration(
                                          milliseconds: 700 + hour * 22,
                                        ),
                                        curve: Curves.easeOutBack,
                                        builder: (context, animated, _) {
                                          final heightFactor = hasActivity
                                              ? animated.clamp(0.08, 1.0)
                                              : 0.05;

                                          return Align(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                              heightFactor: heightFactor,
                                              widthFactor:
                                                  isSelected ? 0.78 : 0.52,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 220,
                                                ),
                                                curve: Curves.easeOutCubic,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                    top: Radius.circular(5),
                                                  ),
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: hasActivity
                                                        ? [
                                                            AppColorPalette
                                                                .primaryDark,
                                                            isSelected
                                                                ? AppColorPalette
                                                                    .primaryLight
                                                                : AppColorPalette
                                                                    .primary,
                                                          ]
                                                        : [
                                                            AppColorPalette
                                                                .primaryDark
                                                                .withValues(
                                                              alpha: 0.35,
                                                            ),
                                                            AppColorPalette
                                                                .primary
                                                                .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                          ],
                                                  ),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: AppColorPalette
                                                                .primary
                                                                .withValues(
                                                              alpha: 0.55,
                                                            ),
                                                            blurRadius: 12,
                                                            spreadRadius: -2,
                                                          ),
                                                        ]
                                                      : isCurrent
                                                          ? [
                                                              BoxShadow(
                                                                color: AppColorPalette
                                                                    .primary
                                                                    .withValues(
                                                                  alpha: 0.25,
                                                                ),
                                                                blurRadius: 6,
                                                              ),
                                                            ]
                                                          : null,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            AppSpacing.sm,
                            AppSpacing.sm,
                            AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _TimeLabel('12:00'),
                              _TimeLabel('6:00'),
                              _TimeLabel('12:00'),
                              _TimeLabel('6:00'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<int>(
            key: ValueKey('total-${widget.totalSteps}'),
            tween: IntTween(begin: 0, end: widget.totalSteps),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedTotal, _) {
              return Text(
                'TOTAL ${_formatNumber(animatedTotal)} STEPS',
                style: TextStyle(
                  color: AppColorPalette.primary.withValues(alpha: 0.92),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatNumber(num value) {
    final text = value.round().toString();
    return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColorPalette.textSecondary.withValues(alpha: 0.7),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _HourlyChartPainter extends CustomPainter {
  const _HourlyChartPainter({
    required this.activeHour,
    required this.currentHour,
  });

  final int activeHour;
  final int currentHour;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawCurrentHourMarker(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 6.0;

    for (var i = 1; i <= 3; i++) {
      final t = i / 4;
      paint.shader = ui.Gradient.linear(
        Offset(0, size.height * t),
        Offset(size.width, size.height * t),
        [
          Colors.transparent,
          AppColorPalette.grey500.withValues(alpha: 0.22),
          Colors.transparent,
        ],
        [0, 0.5, 1],
      );

      _drawDottedLine(
        canvas: canvas,
        paint: paint,
        start: Offset(0, size.height * t),
        end: Offset(size.width, size.height * t),
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      );
    }
  }

  void _drawCurrentHourMarker(Canvas canvas, Size size) {
    final hourWidth = size.width / 24;
    final x = hourWidth * activeHour + hourWidth / 2;

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(x, size.height),
        hourWidth * 1.4,
        [
          AppColorPalette.primary.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      );

    canvas.drawRect(
      Rect.fromLTWH(x - hourWidth * 0.7, 0, hourWidth * 1.4, size.height),
      glowPaint,
    );
  }

  void _drawDottedLine({
    required Canvas canvas,
    required Paint paint,
    required Offset start,
    required Offset end,
    required double dashWidth,
    required double dashSpace,
  }) {
    final path = ui.Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HourlyChartPainter oldDelegate) {
    return oldDelegate.activeHour != activeHour ||
        oldDelegate.currentHour != currentHour;
  }
}
