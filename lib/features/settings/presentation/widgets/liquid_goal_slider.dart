import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';

/// Premium goal slider with an enlarged pill thumb and fluid drag animation.
class LiquidGoalSlider extends StatefulWidget {
  const LiquidGoalSlider({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.displayValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final double value;
  final String displayValue;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  State<LiquidGoalSlider> createState() => _LiquidGoalSliderState();
}

class _LiquidGoalSliderState extends State<LiquidGoalSlider> {
  late double _localValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(LiquidGoalSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.value != widget.value) {
      _localValue = widget.value;
    }
  }

  void _onDragStart(double value) {
    setState(() {
      _isDragging = true;
      _localValue = value;
    });
    HapticFeedback.selectionClick();
  }

  void _onDragUpdate(double value) {
    setState(() => _localValue = value);
  }

  void _onDragEnd(double value) {
    setState(() {
      _isDragging = false;
      _localValue = value;
    });
    widget.onChanged(value);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final progress = ((_localValue - widget.min) / (widget.max - widget.min))
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(color: colors.divider),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: AppColorPalette.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: _isDragging
                      ? AppColorPalette.primary
                      : colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(widget.displayValue),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 36,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const thumbWidth = 52.0;
                const thumbHeight = 28.0;
                final trackWidth = constraints.maxWidth;
                final thumbLeft = (trackWidth - thumbWidth) * progress;

                return Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.progressTrack,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      height: 4,
                      width: trackWidth * progress,
                      decoration: BoxDecoration(
                        color: AppColorPalette.primary.withValues(
                          alpha: isLight ? 0.55 : 0.35,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      left: thumbLeft,
                      child: AnimatedScale(
                        scale: _isDragging ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutBack,
                        child: Container(
                          width: thumbWidth,
                          height: thumbHeight,
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColorPalette.white
                                : AppColorPalette.white,
                            borderRadius: BorderRadius.circular(999),
                            border: isLight
                                ? Border.all(color: colors.divider)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppColorPalette.primary.withValues(
                                  alpha: _isDragging ? 0.35 : 0.18,
                                ),
                                blurRadius: _isDragging ? 16 : 8,
                                spreadRadius: _isDragging ? 1 : 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        thumbShape: const _InvisibleSliderThumbShape(),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 0,
                        ),
                      ),
                      child: Slider(
                        value: _localValue,
                        min: widget.min,
                        max: widget.max,
                        divisions: widget.divisions,
                        onChangeStart: _onDragStart,
                        onChanged: _onDragUpdate,
                        onChangeEnd: _onDragEnd,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Hides the Material slider thumb so only the custom pill thumb is visible.
class _InvisibleSliderThumbShape extends SliderComponentShape {
  const _InvisibleSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
