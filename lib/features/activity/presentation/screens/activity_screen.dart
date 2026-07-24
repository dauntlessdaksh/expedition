import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/activity_bloc.dart';
import '../widgets/activity_controls.dart';
import '../widgets/activity_map.dart';
import '../widgets/workout_panel.dart';

/// Live GPS activity tracking screen with map, metrics, and controls.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColorPalette.darkBackground,
          body: Stack(
            children: [
              const Positioned.fill(child: ActivityMap()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      _TopIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.go(RouteConstants.home),
                      ),
                      const Spacer(),
                      if (!state.followUser && state.currentPosition != null)
                        _TopIconButton(
                          icon: Icons.my_location_rounded,
                          onPressed: () => context.read<ActivityBloc>().add(
                                const RecenterMapRequested(),
                              ),
                        ),
                    ],
                  ),
                ),
              ),
              if (state.errorMessage != null)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 56,
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                      ),
                      child: _ErrorBanner(message: state.errorMessage!),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WorkoutPanel(state: state),
                        SizedBox(height: state.showWorkoutPanel ? AppSpacing.lg : 0),
                        ActivityControls(
                          state: state,
                          onStart: () => context.read<ActivityBloc>().add(
                                const StartTracking(),
                              ),
                          onPause: () => context.read<ActivityBloc>().add(
                                const PauseTracking(),
                              ),
                          onResume: () => context.read<ActivityBloc>().add(
                                const ResumeTracking(),
                              ),
                          onStop: () => context.read<ActivityBloc>().add(
                                const StopTracking(),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: AppColorPalette.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColorPalette.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: AppColorPalette.warning,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColorPalette.grey200,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
