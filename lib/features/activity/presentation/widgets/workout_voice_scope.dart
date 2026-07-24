import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/voice/voice_service.dart';
import '../../../../core/voice/voice_settings.dart';
import '../../../../core/voice/voice_settings_service.dart';
import '../bloc/activity_bloc.dart';
import '../../data/services/workout_voice_coordinator.dart';

/// Bridges live workout metrics to [WorkoutVoiceCoordinator] without
/// modifying [ActivityBloc].
class WorkoutVoiceScope extends StatefulWidget {
  const WorkoutVoiceScope({
    required this.child,
    required this.distanceGoalKm,
    required this.timeGoalMinutes,
    this.voiceSettings,
    this.onVoiceSettingsChanged,
    super.key,
  });

  final Widget child;
  final double distanceGoalKm;
  final int timeGoalMinutes;
  final VoiceSettings? voiceSettings;
  final ValueChanged<VoiceSettings>? onVoiceSettingsChanged;

  static VoiceSettings? maybeSettingsOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_VoiceSettingsScope>()
        ?.settings;
  }

  static ValueChanged<VoiceSettings>? maybeOnChangedOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_VoiceSettingsScope>()
        ?.onChanged;
  }

  @override
  State<WorkoutVoiceScope> createState() => _WorkoutVoiceScopeState();
}

class _WorkoutVoiceScopeState extends State<WorkoutVoiceScope> {
  late final WorkoutVoiceCoordinator _coordinator;
  VoiceSettings _settings = VoiceSettings.defaults;
  bool _wasSessionActive = false;

  @override
  void initState() {
    super.initState();
    _coordinator = WorkoutVoiceCoordinator(
      voiceService: context.read<VoiceService>(),
    );
    _applyExternalSettings(widget.voiceSettings);
    _coordinator.updateGoals(
      distanceGoalKm: widget.distanceGoalKm,
      timeGoalMinutes: widget.timeGoalMinutes,
    );
  }

  @override
  void didUpdateWidget(WorkoutVoiceScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.voiceSettings != null &&
        widget.voiceSettings != oldWidget.voiceSettings) {
      _applyExternalSettings(widget.voiceSettings);
    }

    if (widget.distanceGoalKm != oldWidget.distanceGoalKm ||
        widget.timeGoalMinutes != oldWidget.timeGoalMinutes) {
      _coordinator.updateGoals(
        distanceGoalKm: widget.distanceGoalKm,
        timeGoalMinutes: widget.timeGoalMinutes,
      );
    }
  }

  @override
  void dispose() {
    unawaited(_coordinator.resetSession());
    super.dispose();
  }

  void _applyExternalSettings(VoiceSettings? settings) {
    if (settings == null) {
      return;
    }
    _settings = settings;
    _coordinator.updateSettings(settings);
  }

  WorkoutVoiceSnapshot _toSnapshot(ActivityState state) {
    return WorkoutVoiceSnapshot(
      isTracking: state.status == ActivityTrackingStatus.tracking,
      isPaused: state.status == ActivityTrackingStatus.paused,
      isSaving: state.workoutSaveStatus == ActivityWorkoutSaveStatus.saving,
      isSaved: state.workoutSaveStatus == ActivityWorkoutSaveStatus.saved,
      distanceMeters: state.distanceMeters,
      duration: state.duration,
      currentSpeedMps: state.currentSpeedMps,
      averageSpeedMps: state.averageSpeedMps,
      activeCalories: state.activeCalories,
      elevationGainMeters: state.elevationGainMeters,
      gpsAccuracyMeters: state.gpsAccuracyMeters,
      isHike: state.isHike,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _VoiceSettingsScope(
      settings: _settings,
      onChanged: (next) {
        setState(() => _settings = next);
        _coordinator.updateSettings(next);
        widget.onVoiceSettingsChanged?.call(next);
      },
      child: BlocListener<ActivityBloc, ActivityState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.workoutSaveStatus != current.workoutSaveStatus ||
            previous.distanceMeters != current.distanceMeters ||
            previous.duration != current.duration ||
            previous.currentSpeedMps != current.currentSpeedMps ||
            previous.averageSpeedMps != current.averageSpeedMps ||
            previous.activeCalories != current.activeCalories ||
            previous.gpsAccuracyMeters != current.gpsAccuracyMeters,
        listener: (context, state) {
          final isActive = state.isSessionActive;
          unawaited(_coordinator.handleSnapshot(_toSnapshot(state)));

          if (_wasSessionActive &&
              !isActive &&
              state.workoutSaveStatus == ActivityWorkoutSaveStatus.none) {
            unawaited(_coordinator.resetSession());
          }
          _wasSessionActive = isActive;
        },
        child: widget.child,
      ),
    );
  }
}

class _VoiceSettingsScope extends InheritedWidget {
  const _VoiceSettingsScope({
    required this.settings,
    required this.onChanged,
    required super.child,
  });

  final VoiceSettings settings;
  final ValueChanged<VoiceSettings> onChanged;

  @override
  bool updateShouldNotify(_VoiceSettingsScope oldWidget) {
    return oldWidget.settings != settings;
  }
}

/// Loads voice settings once for the activity screen.
class ActivityVoiceSettingsLoader {
  ActivityVoiceSettingsLoader(this._service);

  final VoiceSettingsService _service;
  VoiceSettings? _cached;

  Future<VoiceSettings> load({bool? legacyVoiceFeedbackEnabled}) async {
    _cached ??= await _service.load(
      legacyVoiceFeedbackEnabled: legacyVoiceFeedbackEnabled,
    );
    return _cached!;
  }

  Future<void> save(VoiceSettings settings) async {
    _cached = settings;
    await _service.save(settings);
  }
}
