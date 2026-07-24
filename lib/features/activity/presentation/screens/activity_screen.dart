import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/navigation/main_tab.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../gamification/presentation/widgets/achievement_celebration_dialog.dart';
import '../bloc/activity_bloc.dart';
import '../widgets/activity_controls.dart';
import '../widgets/activity_map.dart';
import '../widgets/location_permission_panel.dart';
import '../widgets/workout_panel.dart';

/// Live GPS activity tracking screen with map, metrics, and controls.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listenWhen: (previous, current) =>
          previous.workoutSaveStatus != current.workoutSaveStatus ||
          (current.pendingCelebration != null &&
              previous.pendingCelebration == null),
      listener: (context, state) async {
        if (state.workoutSaveStatus == ActivityWorkoutSaveStatus.saved) {
          HapticService.workoutCompleted();
        }

        if (state.workoutSaveStatus != ActivityWorkoutSaveStatus.saved) {
          return;
        }

        if (state.pendingCelebration != null) {
          HapticService.achievementUnlocked();
          await AchievementCelebrationDialog.show(
            context,
            achievement: state.pendingCelebration!,
            gender: state.userGender,
          );
          if (!context.mounted) return;
          context.read<ActivityBloc>().add(const ClearPendingCelebration());
        }

        if (!context.mounted) return;
        MainNavigation.goToTab(context, MainTab.home);
      },
      child: BlocSelector<ActivityBloc, ActivityState, ActivityState>(
        selector: (state) => state,
        builder: (context, state) {
          final showPermissionPanel = state.permissionStatus !=
                  ActivityPermissionStatus.granted &&
              state.permissionStatus != ActivityPermissionStatus.unknown;

          return Scaffold(
            backgroundColor: AppColorPalette.darkBackground,
            body: Stack(
              children: [
                const Positioned.fill(
                  child: RepaintBoundary(child: ActivityMap()),
                ),
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
                          semanticLabel: 'Back to home',
                          onPressed: state.workoutSaveStatus ==
                                  ActivityWorkoutSaveStatus.saving
                              ? null
                              : () =>
                                  MainNavigation.goToTab(context, MainTab.home),
                        ),
                        const Spacer(),
                        if (!state.followUser && state.currentPosition != null)
                          _TopIconButton(
                            icon: Icons.my_location_rounded,
                            semanticLabel: 'Recenter map',
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
                        child: _StatusBannerForState(state: state),
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
                          if (showPermissionPanel) ...[
                            LocationPermissionPanel(
                              permissionStatus: state.permissionStatus,
                              onRetry: () => context
                                  .read<ActivityBloc>()
                                  .add(const ActivityStarted()),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          WorkoutPanel(state: state),
                          SizedBox(
                            height: state.showWorkoutPanel ? AppSpacing.lg : 0,
                          ),
                          ActivityControls(
                            state: state,
                            onStart: () {
                              HapticService.workoutStarted();
                              context.read<ActivityBloc>().add(
                                    const StartTracking(),
                                  );
                            },
                            onPause: () {
                              HapticService.lightImpact();
                              context.read<ActivityBloc>().add(
                                    const PauseTracking(),
                                  );
                            },
                            onResume: () {
                              HapticService.workoutStarted();
                              context.read<ActivityBloc>().add(
                                    const ResumeTracking(),
                                  );
                            },
                            onStop: () {
                              HapticService.heavyImpact();
                              context.read<ActivityBloc>().add(
                                    const StopTracking(),
                                  );
                            },
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
      ),
    );
  }
}

class _StatusBannerForState extends StatelessWidget {
  const _StatusBannerForState({required this.state});

  final ActivityState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.permissionStatus) {
      ActivityPermissionStatus.serviceDisabled =>
        StatusBanner.locationDisabled(),
      ActivityPermissionStatus.deniedForever =>
        StatusBanner.permissionMissing(permanentlyDenied: true),
      ActivityPermissionStatus.denied => StatusBanner.permissionMissing(
          permanentlyDenied: false,
          onRetry: () =>
              context.read<ActivityBloc>().add(const ActivityStarted()),
        ),
      _ => StatusBanner.gpsUnavailable(
          onRetry: () =>
              context.read<ActivityBloc>().add(const ActivityStarted()),
        ),
    };
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: DecoratedBox(
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
              width: 48,
              height: 48,
              child: Icon(
                icon,
                color: onPressed == null
                    ? AppColorPalette.grey600
                    : AppColorPalette.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
