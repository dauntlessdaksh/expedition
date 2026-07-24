import 'dart:async';

import '../../../../core/voice/voice_announcement_builder.dart';
import '../../../../core/voice/voice_service.dart';
import '../../../../core/voice/voice_settings.dart';
import '../../../../core/voice/voice_speech_formatter.dart';

/// Lightweight workout snapshot consumed by voice guidance.
///
/// Keeps the voice layer independent from [ActivityBloc] types.
class WorkoutVoiceSnapshot {
  const WorkoutVoiceSnapshot({
    required this.isTracking,
    required this.isPaused,
    required this.isSaving,
    required this.isSaved,
    required this.distanceMeters,
    required this.duration,
    required this.currentSpeedMps,
    required this.averageSpeedMps,
    required this.activeCalories,
    required this.elevationGainMeters,
    required this.gpsAccuracyMeters,
    required this.isHike,
  });

  final bool isTracking;
  final bool isPaused;
  final bool isSaving;
  final bool isSaved;
  final double distanceMeters;
  final Duration duration;
  final double currentSpeedMps;
  final double averageSpeedMps;
  final int activeCalories;
  final double elevationGainMeters;
  final double gpsAccuracyMeters;
  final bool isHike;
}

enum _GpsVoiceStatus {
  searching,
  good,
  fair,
  weak,
}

enum _WorkoutVoicePhase {
  idle,
  active,
  paused,
}

/// Observes workout snapshots and enqueues voice announcements.
class WorkoutVoiceCoordinator {
  WorkoutVoiceCoordinator({
    required VoiceService voiceService,
  })  : _voiceService = voiceService,
        _builder = voiceService.announcements;

  final VoiceService _voiceService;
  final VoiceAnnouncementBuilder _builder;

  VoiceSettings _settings = VoiceSettings.defaults;
  double _distanceGoalKm = 5;
  int _timeGoalMinutes = 30;

  _WorkoutVoicePhase _phase = _WorkoutVoicePhase.idle;
  bool _wasSaved = false;
  int _lastDistanceMarker = 0;
  int _lastTimeInterval = 0;
  bool _distanceGoalAnnounced = false;
  bool _timeGoalAnnounced = false;
  _GpsVoiceStatus? _lastGpsStatus;

  WorkoutVoiceSnapshot? _completionSnapshot;
  Future<void> _handleChain = Future<void>.value();

  void updateSettings(VoiceSettings settings) {
    final wasEnabled = _settings.enabled;
    _settings = settings;
    unawaited(_voiceService.applySettings(settings));
    if (wasEnabled && !settings.enabled) {
      unawaited(_voiceService.stop());
    }
  }

  void updateGoals({
    required double distanceGoalKm,
    required int timeGoalMinutes,
  }) {
    _distanceGoalKm = distanceGoalKm;
    _timeGoalMinutes = timeGoalMinutes;
  }

  Future<void> handleSnapshot(WorkoutVoiceSnapshot snapshot) {
    _handleChain = _handleChain.then((_) => _processSnapshot(snapshot));
    return _handleChain;
  }

  Future<void> _processSnapshot(WorkoutVoiceSnapshot snapshot) async {
    if (!_settings.enabled) {
      return;
    }

    if (snapshot.isSaved && !_wasSaved && _completionSnapshot != null) {
      await _announceCompletion();
      await resetSession();
      _wasSaved = true;
      return;
    }

    if (snapshot.isSaving) {
      _completionSnapshot = snapshot;
    }

    await _maybeAnnounceLifecycle(snapshot);

    if (snapshot.isTracking && !snapshot.isPaused) {
      await _maybeAnnounceDistance(snapshot);
      await _maybeAnnounceTimeInterval(snapshot);
      await _maybeAnnounceGoals(snapshot);
    }

    if (_settings.content.gpsStatus) {
      await _maybeAnnounceGpsStatus(snapshot.gpsAccuracyMeters);
    }
  }

  Future<void> _maybeAnnounceLifecycle(WorkoutVoiceSnapshot snapshot) async {
    if (snapshot.isTracking && !snapshot.isPaused) {
      if (_phase == _WorkoutVoicePhase.idle) {
        _phase = _WorkoutVoicePhase.active;
        await _voiceService.speak(_builder.workoutStarted());
      } else if (_phase == _WorkoutVoicePhase.paused) {
        _phase = _WorkoutVoicePhase.active;
        await _voiceService.speak(_builder.workoutResumed());
      }
      return;
    }

    if (snapshot.isPaused && _phase == _WorkoutVoicePhase.active) {
      _phase = _WorkoutVoicePhase.paused;
      await _voiceService.speak(_builder.workoutPaused());
    }
  }

  Future<void> resetSession() async {
    _phase = _WorkoutVoicePhase.idle;
    _wasSaved = false;
    _lastDistanceMarker = 0;
    _lastTimeInterval = 0;
    _distanceGoalAnnounced = false;
    _timeGoalAnnounced = false;
    _lastGpsStatus = null;
    _completionSnapshot = null;
    await _voiceService.stop();
  }

  Future<void> _maybeAnnounceDistance(WorkoutVoiceSnapshot snapshot) async {
    final intervalMeters = _settings.announcementDistance.meters;
    if (intervalMeters <= 0) {
      return;
    }

    final marker = (snapshot.distanceMeters / intervalMeters).floor();
    if (marker <= _lastDistanceMarker || marker <= 0) {
      return;
    }

    _lastDistanceMarker = marker;
    await _voiceService.speak(
      _builder.distanceMilestone(
        markerIndex: marker,
        intervalMeters: intervalMeters,
        elapsed: snapshot.duration,
        averageSpeedMps: snapshot.averageSpeedMps,
        currentSpeedMps: snapshot.currentSpeedMps,
        calories: snapshot.activeCalories,
        content: _settings.content,
      ),
    );
  }

  Future<void> _maybeAnnounceTimeInterval(WorkoutVoiceSnapshot snapshot) async {
    final minutes = _settings.timeInterval.minutes;
    if (minutes <= 0) {
      return;
    }

    final intervalSeconds = minutes * 60;
    final currentInterval = snapshot.duration.inSeconds ~/ intervalSeconds;
    if (currentInterval <= _lastTimeInterval || currentInterval <= 0) {
      return;
    }

    _lastTimeInterval = currentInterval;
    await _voiceService.speak(
      _builder.timeCheckpoint(
        elapsed: snapshot.duration,
        distanceMeters: snapshot.distanceMeters,
        averageSpeedMps: snapshot.averageSpeedMps,
        calories: snapshot.activeCalories,
        content: _settings.content,
      ),
    );
  }

  Future<void> _maybeAnnounceGoals(WorkoutVoiceSnapshot snapshot) async {
    if (!_distanceGoalAnnounced &&
        snapshot.distanceMeters >= _distanceGoalKm * 1000) {
      _distanceGoalAnnounced = true;
      await _voiceService.speak(_builder.distanceGoalCompleted());
    }

    if (!_timeGoalAnnounced &&
        snapshot.duration.inMinutes >= _timeGoalMinutes) {
      _timeGoalAnnounced = true;
      await _voiceService.speak(_builder.timeGoalCompleted());
    }
  }

  Future<void> _maybeAnnounceGpsStatus(double accuracyMeters) async {
    final status = _gpsStatusFor(accuracyMeters);
    if (_lastGpsStatus == null) {
      _lastGpsStatus = status;
      return;
    }
    if (_lastGpsStatus == status) {
      return;
    }

    _lastGpsStatus = status;
    await _voiceService.speak(VoiceSpeechFormatter.gpsStatus(accuracyMeters));
  }

  _GpsVoiceStatus _gpsStatusFor(double accuracyMeters) {
    if (accuracyMeters <= 0) {
      return _GpsVoiceStatus.searching;
    }
    if (accuracyMeters <= 12) {
      return _GpsVoiceStatus.good;
    }
    if (accuracyMeters <= 25) {
      return _GpsVoiceStatus.fair;
    }
    return _GpsVoiceStatus.weak;
  }

  Future<void> _announceCompletion() async {
    await _voiceService.speak(_builder.workoutCompleted());
  }
}
