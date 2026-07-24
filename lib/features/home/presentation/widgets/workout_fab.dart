import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/hold_to_confirm_button.dart';

/// Primary call-to-action to start a new outdoor activity.
class WorkoutFab extends StatelessWidget {
  const WorkoutFab({
    required this.onPressed,
    this.inline = false,
    super.key,
  });

  static const _holdDuration = Duration(milliseconds: 1200);

  final VoidCallback onPressed;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final button = HoldToConfirmButton(
      holdDuration: _holdDuration,
      semanticLabel: 'Start activity',
      borderColor: AppColorPalette.primaryLight,
      onConfirmed: () {
        HapticService.workoutStarted();
        onPressed();
      },
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: PremiumGradients.accentButton,
            borderRadius: AppBorderRadius.radiusFull,
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.primary.withValues(alpha: 0.38),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: AppColorPalette.white,
                size: 28,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Start Activity',
                style: TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (inline) {
      return button;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: button,
      ),
    );
  }
}
