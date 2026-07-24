import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Premium goal slider with an enlarged pill thumb and fluid drag animation.
class LiquidGoalSlider extends StatefulWidget {
  const LiquidGoalSlider({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.formatValue,
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
  final String Function(double value) formatValue;
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
        color: AppColorPalette.darkCard,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.7),
        ),
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
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: _isDragging
                      ? AppColorPalette.white
                      : AppColorPalette.grey400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(widget.formatValue(_localValue)),
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
                final thumbLeft =
                    (trackWidth - thumbWidth) * progress;

                return Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColorPalette.darkCardElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      height: 4,
                      width: trackWidth * progress,
                      decoration: BoxDecoration(
                        color: AppColorPalette.white.withValues(alpha: 0.18),
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
                            color: AppColorPalette.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorPalette.white
                                    .withValues(alpha: _isDragging ? 0.35 : 0.2),
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
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 18,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 28,
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
