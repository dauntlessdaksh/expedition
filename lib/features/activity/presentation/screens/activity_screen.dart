import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/navigation/main_tab.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/voice/voice_settings.dart';
import '../../../../core/voice/voice_settings_service.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../gamification/presentation/widgets/achievement_celebration_dialog.dart';
import '../../../spotify/presentation/bloc/spotify_bloc.dart';
import '../../../spotify/presentation/widgets/spotify_mini_player.dart';
import '../../../spotify/presentation/widgets/spotify_player_sheet.dart';
import '../../data/models/activity_preferences.dart';
import '../../data/models/activity_type.dart';
import '../../data/services/activity_preferences_service.dart';
import '../bloc/activity_bloc.dart';
import '../widgets/activity_bottom_sheets.dart';
import '../widgets/activity_live_metrics.dart';
import '../widgets/activity_map.dart';
import '../widgets/activity_premium_controls.dart';
import '../widgets/location_permission_panel.dart';
import '../widgets/workout_voice_scope.dart';

/// Live GPS activity tracking with premium map overlay, voice assist, and controls.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _preferencesService = ActivityPreferencesService();
  late final ActivityVoiceSettingsLoader _voiceSettingsLoader;

  ActivityPreferences _preferences = ActivityPreferences.defaults;
  VoiceSettings _voiceSettings = VoiceSettings.defaults;
  bool _prefsLoaded = false;
  bool _voiceSettingsLoaded = false;
  bool _isLocked = false;
  int? _countdownValue;
  bool _openPlayerWhenConnected = false;

  @override
  void initState() {
    super.initState();
    _voiceSettingsLoader = ActivityVoiceSettingsLoader(
      context.read<VoiceSettingsService>(),
    );
    _loadPreferences();
    _loadVoiceSettings();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _preferencesService.load();
    if (!mounted) return;
    setState(() {
      _preferences = prefs;
      _prefsLoaded = true;
    });
  }

  Future<void> _loadVoiceSettings() async {
    final settings = await _voiceSettingsLoader.load();
    if (!mounted) return;
    setState(() {
      _voiceSettings = settings;
      _voiceSettingsLoaded = true;
    });
  }

  Future<void> _savePreferences(ActivityPreferences prefs) async {
    setState(() => _preferences = prefs);
    await _preferencesService.save(prefs);
  }

  Future<void> _saveVoiceSettings(VoiceSettings settings) async {
    setState(() => _voiceSettings = settings);
    await _voiceSettingsLoader.save(settings);
  }

  void _toggleVoiceAnnouncements() {
    final nextEnabled = !_voiceSettings.enabled;
    _saveVoiceSettings(_voiceSettings.copyWith(enabled: nextEnabled));
    HapticService.selection();
  }

  Future<void> _startWorkout() async {
    if (_preferences.countdownEnabled && _preferences.countdownSeconds > 0) {
      setState(() => _countdownValue = _preferences.countdownSeconds);
      await _runCountdown();
      if (!mounted) return;
      setState(() => _countdownValue = null);
    }

    if (!mounted) return;
    HapticService.workoutStarted();
    context.read<ActivityBloc>().add(const StartTracking());
  }

  Future<void> _runCountdown() async {
    while (_countdownValue != null && _countdownValue! > 0) {
      if (_preferences.vibration) {
        HapticService.lightImpact();
      }
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _countdownValue = (_countdownValue ?? 1) - 1);
    }
    if (_preferences.vibration) {
      HapticService.heavyImpact();
    }
  }

  void _openActivitySelection() {
    showActivitySelectionSheet(
      context: context,
      selected: _preferences.activityType,
      onSelected: (type) {
        _savePreferences(_preferences.copyWith(activityType: type));
      },
    );
  }

  void _openActivitySettings() {
    showActivitySettingsSheet(
      context: context,
      preferences: _preferences,
      onSave: _savePreferences,
      voiceSettings: _voiceSettings,
      onVoiceSettingsChanged: _saveVoiceSettings,
    );
  }

  void _onMusicTap() {
    final bloc = context.read<SpotifyBloc>();
    final spotifyState = bloc.state;
    if (spotifyState.isConnected) {
      SpotifyPlayerSheet.show(context, bloc: bloc);
      return;
    }

    if (spotifyState.isAuthenticated) {
      _openPlayerWhenConnected = true;
      bloc.add(const EnsureSpotifyRemoteConnected());
      return;
    }

    _openPlayerWhenConnected = true;
    bloc.add(const ConnectSpotify());
  }

  Future<void> _showCancelOptions() async {
    final shouldEnd = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColorPalette.darkCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'End workout?',
                  style: TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(
                  Icons.stop_circle_outlined,
                  color: AppColorPalette.error,
                ),
                title: const Text(
                  'End & Save',
                  style: TextStyle(
                    color: AppColorPalette.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, true),
              ),
              ListTile(
                leading: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColorPalette.white,
                ),
                title: const Text(
                  'Keep Going',
                  style: TextStyle(color: AppColorPalette.white),
                ),
                onTap: () => Navigator.pop(sheetContext, false),
              ),
            ],
          ),
        );
      },
    );

    if (shouldEnd == true && mounted) {
      HapticService.heavyImpact();
      context.read<ActivityBloc>().add(const StopTracking());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded || !_voiceSettingsLoaded) {
      return Scaffold(
        backgroundColor: context.expeditionColors.scaffoldBackground,
        body: const Center(
          child: CircularProgressIndicator(color: AppColorPalette.primary),
        ),
      );
    }

    return WorkoutVoiceScope(
      voiceSettings: _voiceSettings,
      onVoiceSettingsChanged: _saveVoiceSettings,
      distanceGoalKm: _preferences.distanceGoalKm,
      timeGoalMinutes: _preferences.timeGoalMinutes,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ActivityBloc, ActivityState>(
            listenWhen: (previous, current) {
              final justSaved = previous.workoutSaveStatus !=
                      ActivityWorkoutSaveStatus.saved &&
                  current.workoutSaveStatus ==
                      ActivityWorkoutSaveStatus.saved;
              final celebrationArrived = current.pendingCelebration != null &&
                  previous.pendingCelebration == null;
              final sessionEnded = previous.isSessionActive &&
                  !current.isSessionActive;
              return justSaved || celebrationArrived || sessionEnded;
            },
            listener: (context, state) async {
              if (!state.isSessionActive && _isLocked) {
                setState(() => _isLocked = false);
              }

              final justSaved = state.workoutSaveStatus ==
                  ActivityWorkoutSaveStatus.saved;
              if (!justSaved) {
                return;
              }

              HapticService.workoutCompleted();

              if (state.pendingCelebration != null) {
                HapticService.achievementUnlocked();
                await AchievementCelebrationDialog.show(
                  context,
                  achievement: state.pendingCelebration!,
                  gender: state.userGender,
                );
                if (!context.mounted) return;
                context
                    .read<ActivityBloc>()
                    .add(const ClearPendingCelebration());
              }

              if (!context.mounted) return;

              final workoutId = state.savedWorkoutId;
              if (workoutId != null) {
                MainNavigation.goToTab(context, MainTab.history);
                await context.push(RouteConstants.historyDetailPath(workoutId));
              }

              if (!context.mounted) return;
              context.read<ActivityBloc>().add(
                    const ClearSavedWorkoutNavigation(),
                  );
            },
          ),
          BlocListener<SpotifyBloc, SpotifyState>(
            listenWhen: (previous, current) =>
                previous.isConnected != current.isConnected ||
                previous.errorMessage != current.errorMessage,
            listener: (context, state) {
              if (_openPlayerWhenConnected && state.isConnected) {
                _openPlayerWhenConnected = false;
                final bloc = context.read<SpotifyBloc>();
                SpotifyPlayerSheet.show(context, bloc: bloc);
              }

              final message = state.errorMessage;
              if (message != null && message.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ActivityBloc, ActivityState>(
          buildWhen: (previous, current) =>
              previous.permissionStatus != current.permissionStatus ||
              previous.isSessionActive != current.isSessionActive ||
              previous.workoutSaveStatus != current.workoutSaveStatus ||
              previous.status != current.status ||
              previous.errorMessage != current.errorMessage ||
              previous.followUser != current.followUser ||
              previous.currentPosition != current.currentPosition ||
              previous.distanceMeters != current.distanceMeters ||
              previous.duration != current.duration ||
              previous.currentSpeedMps != current.currentSpeedMps ||
              previous.activeCalories != current.activeCalories ||
              previous.currentAltitudeMeters != current.currentAltitudeMeters,
          builder: (context, state) {
            final isTracking = state.isSessionActive;
            final isSaving =
                state.workoutSaveStatus == ActivityWorkoutSaveStatus.saving;
            final showPermissionPanel = state.permissionStatus !=
                    ActivityPermissionStatus.granted &&
                state.permissionStatus != ActivityPermissionStatus.unknown;
            final canStart = state.permissionStatus ==
                    ActivityPermissionStatus.granted &&
                state.status != ActivityTrackingStatus.locating &&
                !isSaving;

            return Scaffold(
              backgroundColor: AppColorPalette.darkBackground,
              body: Stack(
                children: [
                  const Positioned.fill(
                    child: RepaintBoundary(child: ActivityMap()),
                  ),
                  if (!isTracking)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          0,
                        ),
                        child: _ActivityHeader(
                          activityType: _preferences.activityType,
                          preferences: _preferences,
                          onDistanceTap: _openActivitySettings,
                          onTimeTap: _openActivitySettings,
                          onCountdownTap: _openActivitySettings,
                        ),
                      ),
                    ),
                  if (isTracking && !_isLocked)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: ActivityLiveMetricsPanel(state: state),
                        ),
                      ),
                    ),
                  if (!isTracking)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          child: state.followUser ||
                                  state.currentPosition == null
                              ? const SizedBox.shrink()
                              : ActivityFloatingButton(
                                  icon: Icons.my_location_rounded,
                                  onTap: () => context
                                      .read<ActivityBloc>()
                                      .add(const RecenterMapRequested()),
                                ),
                        ),
                      ),
                    ),
                  if (state.errorMessage != null)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 120,
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showPermissionPanel && !isTracking)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              child: LocationPermissionPanel(
                                permissionStatus: state.permissionStatus,
                                onRetry: () => context
                                    .read<ActivityBloc>()
                                    .add(const ActivityStarted()),
                              ),
                            ),
                          if (!isTracking)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.xl,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: isSaving
                                    ? const SizedBox(
                                        key: ValueKey('saving'),
                                        height: 88,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColorPalette.primary,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      )
                                    : ActivityPreStartControls(
                                        key: const ValueKey('start'),
                                        activityType: _preferences.activityType,
                                        enabled: canStart,
                                        onActivityTap: _openActivitySelection,
                                        onStart: _startWorkout,
                                        onSettingsTap: _openActivitySettings,
                                      ),
                              ),
                            )
                          else if (!_isLocked) ...[
                            const SpotifyMiniPlayer(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              child: ActivityTrackingControls(
                                isPaused: state.status ==
                                    ActivityTrackingStatus.paused,
                                duration: state.duration,
                                voiceEnabled: _voiceSettings.enabled,
                                onCancel: _showCancelOptions,
                                onPauseResume: () {
                                  if (state.status ==
                                      ActivityTrackingStatus.paused) {
                                    HapticService.workoutStarted();
                                    context
                                        .read<ActivityBloc>()
                                        .add(const ResumeTracking());
                                  } else {
                                    HapticService.lightImpact();
                                    context
                                        .read<ActivityBloc>()
                                        .add(const PauseTracking());
                                  }
                                },
                                onLock: () => setState(() => _isLocked = true),
                                onMusicTap: _onMusicTap,
                                onMuteTap: _toggleVoiceAnnouncements,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_isLocked && isTracking)
                    Positioned.fill(
                      child: ActivityLockOverlay(
                        duration: state.duration,
                        isPaused:
                            state.status == ActivityTrackingStatus.paused,
                        voiceEnabled: _voiceSettings.enabled,
                        onUnlock: () => setState(() => _isLocked = false),
                        onMusicTap: _onMusicTap,
                        onMuteTap: _toggleVoiceAnnouncements,
                      ),
                    ),
                  if (_countdownValue != null && _countdownValue! > 0)
                    Positioned.fill(
                      child: ActivityCountdownOverlay(
                        seconds: _countdownValue!,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({
    required this.activityType,
    required this.preferences,
    required this.onDistanceTap,
    required this.onTimeTap,
    required this.onCountdownTap,
  });

  final ActivityType activityType;
  final ActivityPreferences preferences;
  final VoidCallback onDistanceTap;
  final VoidCallback onTimeTap;
  final VoidCallback onCountdownTap;

  @override
  Widget build(BuildContext context) {
    final countdownLabel = preferences.countdownEnabled
        ? '${preferences.countdownSeconds}s'
        : 'Off';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              activityType.emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              activityType.label,
              style: const TextStyle(
                color: AppColorPalette.primary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ActivityGoalChip(
              icon: Icons.place_rounded,
              iconColor: const Color(0xFF60A5FA),
              label: '${preferences.distanceGoalKm.toStringAsFixed(1)} km',
              onTap: onDistanceTap,
            ),
            ActivityGoalChip(
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFFA78BFA),
              label: '${preferences.timeGoalMinutes} min',
              onTap: onTimeTap,
            ),
            ActivityGoalChip(
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFFFBBF24),
              label: countdownLabel,
              onTap: onCountdownTap,
            ),
          ],
        ),
      ],
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
