import 'package:flutter/material.dart';

import '../constants/app_border_radius.dart';
import '../constants/app_colors.dart';
import '../services/haptic_service.dart';

/// Requires press-and-hold until a rectangular border completes one lap.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    required this.onConfirmed,
    required this.child,
    required this.semanticLabel,
    this.holdDuration = const Duration(milliseconds: 1200),
    this.enabled = true,
    this.borderColor = AppColorPalette.primaryLight,
    this.completedBorderColor = AppColorPalette.white,
    this.onHoldStart,
    super.key,
  });

  final VoidCallback onConfirmed;
  final Widget child;
  final String semanticLabel;
  final Duration holdDuration;
  final bool enabled;
  final Color borderColor;
  final Color completedBorderColor;
  final VoidCallback? onHoldStart;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.holdDuration)
      ..addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void didUpdateWidget(covariant HoldToConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdDuration != widget.holdDuration) {
      _controller.duration = widget.holdDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || _confirmed || !widget.enabled) {
      return;
    }

    _confirmed = true;
    widget.onConfirmed();
  }

  void _startHold() {
    if (!widget.enabled || _confirmed) return;

    _confirmed = false;
    widget.onHoldStart?.call();
    HapticService.lightImpact();
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reset();
      _confirmed = false;
      return;
    }
    _controller.reset();
    _confirmed = false;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: '${widget.semanticLabel}. Press and hold to confirm.',
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _startHold(),
        onPointerUp: (_) => _cancelHold(),
        onPointerCancel: (_) => _cancelHold(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final isActive = progress > 0 && progress < 1;

            return Stack(
              fit: StackFit.passthrough,
              children: [
                Opacity(
                  opacity: widget.enabled ? 1 : 0.55,
                  child: child,
                ),
                if (isActive || progress >= 1)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _RectHoldBorderPainter(
                          progress: progress.clamp(0, 1),
                          color: progress >= 1
                              ? widget.completedBorderColor
                              : widget.borderColor,
                          borderRadius: AppBorderRadius.radiusLg,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class _RectHoldBorderPainter extends CustomPainter {
  const _RectHoldBorderPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
  });

  final double progress;
  final Color color;
  final BorderRadius borderRadius;

  static const _strokeWidth = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rect = Rect.fromLTWH(
      _strokeWidth,
      _strokeWidth,
      size.width - _strokeWidth * 2,
      size.height - _strokeWidth * 2,
    );

    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final animatedPath = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      animatedPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RectHoldBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
