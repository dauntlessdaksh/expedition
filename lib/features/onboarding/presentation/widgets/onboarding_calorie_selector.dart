import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Animated calorie goal selector with +/- controls.
class OnboardingCalorieSelector extends StatefulWidget {
  const OnboardingCalorieSelector({
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 200,
    this.max = 2000,
    this.step = 50,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;

  @override
  State<OnboardingCalorieSelector> createState() =>
      _OnboardingCalorieSelectorState();
}

class _OnboardingCalorieSelectorState extends State<OnboardingCalorieSelector> {
  late int _displayValue;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
  }

  @override
  void didUpdateWidget(OnboardingCalorieSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _displayValue = widget.value;
    }
  }

  void _decrement() {
    if (widget.value - widget.step >= widget.min) {
      widget.onChanged(widget.value - widget.step);
    }
  }

  void _increment() {
    if (widget.value + widget.step <= widget.max) {
      widget.onChanged(widget.value + widget.step);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CalorieButton(
            icon: Icons.remove_rounded,
            onTap: widget.value - widget.step >= widget.min ? _decrement : null,
          ),
          const SizedBox(width: AppSpacing.xxxl),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: _displayValue.toDouble(),
                end: widget.value.toDouble(),
              ),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              onEnd: () => _displayValue = widget.value,
              builder: (context, animatedValue, _) {
                return Column(
                  children: [
                    Text(
                      animatedValue.round().toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColorPalette.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'CALORIES / DAY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColorPalette.grey400.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.xxxl),
          _CalorieButton(
            icon: Icons.add_rounded,
            onTap: widget.value + widget.step <= widget.max ? _increment : null,
          ),
        ],
      ),
    );
  }
}

class _CalorieButton extends StatelessWidget {
  const _CalorieButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled ? PremiumGradients.accentButton : null,
              color: enabled ? null : AppColorPalette.darkCardElevated,
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColorPalette.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: AppColorPalette.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
