import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/hold_to_confirm_button.dart';
import '../bloc/activity_bloc.dart';

/// Start, pause, resume, and stop controls with hold-to-confirm gestures.
class ActivityControls extends StatelessWidget {
  const ActivityControls({
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    super.key,
  });

  static const _startHold = Duration(milliseconds: 1200);
  static const _pauseHold = Duration(milliseconds: 1400);
  static const _stopHold = Duration(milliseconds: 1800);
  static const _resumeHold = Duration(milliseconds: 1000);

  final ActivityState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final isSaving =
        state.workoutSaveStatus == ActivityWorkoutSaveStatus.saving;

    if (isSaving) {
      return const SizedBox(
        key: ValueKey('saving'),
        height: 58,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColorPalette.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: switch (state.status) {
        ActivityTrackingStatus.tracking => _TrackingControls(
            key: const ValueKey('tracking'),
            onPause: onPause,
            onStop: onStop,
          ),
        ActivityTrackingStatus.paused => _PausedControls(
            key: const ValueKey('paused'),
            onResume: onResume,
            onStop: onStop,
          ),
        _ => _StartControl(
            key: const ValueKey('start'),
            onStart: onStart,
            isEnabled: state.permissionStatus ==
                    ActivityPermissionStatus.granted &&
                state.status != ActivityTrackingStatus.locating,
          ),
      },
    );
  }
}

class _StartControl extends StatelessWidget {
  const _StartControl({
    required this.onStart,
    required this.isEnabled,
    super.key,
  });

  final VoidCallback onStart;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return HoldToConfirmButton(
      enabled: isEnabled,
      holdDuration: ActivityControls._startHold,
      semanticLabel: 'Start workout',
      borderColor: AppColorPalette.primaryLight,
      onConfirmed: onStart,
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isEnabled
                ? PremiumGradients.accentButton
                : const LinearGradient(
                    colors: [
                      AppColorPalette.grey700,
                      AppColorPalette.grey800,
                    ],
                  ),
            borderRadius: AppBorderRadius.radiusLg,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColorPalette.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: isEnabled
                    ? AppColorPalette.white
                    : AppColorPalette.grey500,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isEnabled ? 'Hold to Start' : 'Locating...',
                style: TextStyle(
                  color: isEnabled
                      ? AppColorPalette.white
                      : AppColorPalette.grey500,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackingControls extends StatelessWidget {
  const _TrackingControls({
    required this.onPause,
    required this.onStop,
    super.key,
  });

  final VoidCallback onPause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SecondaryButton(
            label: 'Hold to Pause',
            icon: Icons.pause_rounded,
            holdDuration: ActivityControls._pauseHold,
            semanticLabel: 'Pause workout',
            onPressed: onPause,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _PrimaryButton(
            label: 'Hold to Stop',
            icon: Icons.stop_rounded,
            holdDuration: ActivityControls._stopHold,
            semanticLabel: 'Stop workout',
            onPressed: onStop,
            isDestructive: true,
          ),
        ),
      ],
    );
  }
}

class _PausedControls extends StatelessWidget {
  const _PausedControls({
    required this.onResume,
    required this.onStop,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PrimaryButton(
            label: 'Hold to Resume',
            icon: Icons.play_arrow_rounded,
            holdDuration: ActivityControls._resumeHold,
            semanticLabel: 'Resume workout',
            onPressed: onResume,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SecondaryButton(
            label: 'Hold to Stop',
            icon: Icons.stop_rounded,
            holdDuration: ActivityControls._stopHold,
            semanticLabel: 'Stop workout',
            onPressed: onStop,
            borderColor: AppColorPalette.error,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.holdDuration,
    required this.semanticLabel,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Duration holdDuration;
  final String semanticLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive ? AppColorPalette.error : AppColorPalette.primary;

    return HoldToConfirmButton(
      holdDuration: holdDuration,
      semanticLabel: semanticLabel,
      borderColor: isDestructive
          ? AppColorPalette.error
          : AppColorPalette.primaryLight,
      completedBorderColor:
          isDestructive ? AppColorPalette.error : AppColorPalette.white,
      onConfirmed: onPressed,
      child: SizedBox(
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDestructive
                ? LinearGradient(
                    colors: [
                      AppColorPalette.error,
                      AppColorPalette.error.withValues(alpha: 0.85),
                    ],
                  )
                : PremiumGradients.accentButton,
            borderRadius: AppBorderRadius.radiusLg,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColorPalette.white, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.holdDuration,
    required this.semanticLabel,
    this.borderColor = AppColorPalette.primaryLight,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Duration holdDuration;
  final String semanticLabel;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return HoldToConfirmButton(
      holdDuration: holdDuration,
      semanticLabel: semanticLabel,
      borderColor: borderColor,
      onConfirmed: onPressed,
      child: SizedBox(
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColorPalette.darkCardElevated,
            borderRadius: AppBorderRadius.radiusLg,
            border: Border.all(
              color: AppColorPalette.grey700.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColorPalette.white, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
