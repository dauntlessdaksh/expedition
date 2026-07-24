import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../bloc/activity_bloc.dart';

/// Start, pause, resume, and stop controls for live activity tracking.
class ActivityControls extends StatelessWidget {
  const ActivityControls({
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    super.key,
  });

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
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isEnabled
              ? PremiumGradients.accentButton
              : LinearGradient(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onStart : null,
            borderRadius: AppBorderRadius.radiusLg,
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
                  stateLabel(isEnabled),
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
      ),
    );
  }

  String stateLabel(bool enabled) {
    if (!enabled) {
      return 'Locating...';
    }
    return 'Start';
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
            label: 'Pause',
            icon: Icons.pause_rounded,
            onPressed: onPause,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _PrimaryButton(
            label: 'Stop',
            icon: Icons.stop_rounded,
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
            label: 'Resume',
            icon: Icons.play_arrow_rounded,
            onPressed: onResume,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SecondaryButton(
            label: 'Stop',
            icon: Icons.stop_rounded,
            onPressed: onStop,
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
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              color: (isDestructive
                      ? AppColorPalette.error
                      : AppColorPalette.primary)
                  .withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppBorderRadius.radiusLg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColorPalette.white, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
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
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColorPalette.darkCardElevated,
          borderRadius: AppBorderRadius.radiusLg,
          border: Border.all(
            color: AppColorPalette.grey700.withValues(alpha: 0.7),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppBorderRadius.radiusLg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColorPalette.white, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
