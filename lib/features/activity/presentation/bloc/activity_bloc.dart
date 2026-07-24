import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/gps/gps_engine.dart';
import '../../../../core/gps/gps_engine_config.dart';
import '../../../../core/utils/gradient_polyline.dart';
import '../../../../core/services/permission_service.dart';
import '../../../gamification/data/repositories/gamification_repository.dart';
import '../../../gamification/domain/models/gamification_models.dart';
import '../../../history/domain/models/workout.dart';
import '../../../history/data/repositories/workout_repository.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../shared/utils/workout_calorie_calculator.dart';
import '../../data/services/location_service.dart';

part 'activity_event.dart';
part 'activity_state.dart';

/// Manages live GPS activity tracking state in memory.
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc({
    required LocationService locationService,
    required WorkoutRepository workoutRepository,
    required OnboardingRepository onboardingRepository,
    required GamificationRepository gamificationRepository,
    GpsEngine? gpsEngine,
  })  : _locationService = locationService,
        _workoutRepository = workoutRepository,
        _onboardingRepository = onboardingRepository,
        _gamificationRepository = gamificationRepository,
        _gpsEngine = gpsEngine ?? GpsEngine(config: GpsEngineConfig.running()),
        super(const ActivityState()) {
    on<ActivityStarted>(_onStarted);
    on<ActivityPreviewStopped>(_onPreviewStopped);
    on<StartTracking>(_onStartTracking);
    on<PauseTracking>(_onPauseTracking);
    on<ResumeTracking>(_onResumeTracking);
    on<StopTracking>(_onStopTracking);
    on<LocationUpdated>(_onLocationUpdated);
    on<DurationTicked>(_onDurationTicked);
    on<FollowUserToggled>(_onFollowUserToggled);
    on<RecenterMapRequested>(_onRecenterMapRequested);
    on<ClearPendingCelebration>(_onClearPendingCelebration);
    on<ClearSavedWorkoutNavigation>(_onClearSavedWorkoutNavigation);
  }

  static const _activityType = 'outdoor_run';

  final LocationService _locationService;
  final WorkoutRepository _workoutRepository;
  final OnboardingRepository _onboardingRepository;
  final GamificationRepository _gamificationRepository;
  final GpsEngine _gpsEngine;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _durationTimer;

  DateTime? _sessionStartTime;

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    ActivityStarted event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(
      status: ActivityTrackingStatus.locating,
      workoutSaveStatus: ActivityWorkoutSaveStatus.none,
      clearSavedWorkoutId: true,
      clearError: true,
    ));

    final access = await PermissionService.checkLocationAccess();
    switch (access) {
      case LocationAccessStatus.serviceDisabled:
        emit(state.copyWith(
          status: ActivityTrackingStatus.ready,
          permissionStatus: ActivityPermissionStatus.serviceDisabled,
          errorMessage: FailureMapper.from(
            StateError('location service disabled'),
          ).message,
        ));
        return;
      case LocationAccessStatus.deniedForever:
        emit(state.copyWith(
          status: ActivityTrackingStatus.ready,
          permissionStatus: ActivityPermissionStatus.deniedForever,
          errorMessage: FailureMapper.from(
            StateError('permission denied forever'),
          ).message,
        ));
        return;
      case LocationAccessStatus.denied:
        emit(state.copyWith(
          status: ActivityTrackingStatus.ready,
          permissionStatus: ActivityPermissionStatus.denied,
          errorMessage: FailureMapper.from(
            StateError('location permission denied'),
          ).message,
        ));
        return;
      case LocationAccessStatus.granted:
        break;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        emit(state.copyWith(
          status: ActivityTrackingStatus.ready,
          permissionStatus: ActivityPermissionStatus.denied,
          errorMessage: FailureMapper.from(
            StateError('location unavailable'),
          ).message,
        ));
        return;
      }

      emit(state.copyWith(
        status: ActivityTrackingStatus.ready,
        permissionStatus: ActivityPermissionStatus.granted,
        currentPosition: LatLng(position.latitude, position.longitude),
        gpsAccuracyMeters: position.accuracy,
        followUser: true,
        clearError: true,
      ));

      await _startLocationPreview();
    } on TimeoutException {
      emit(state.copyWith(
        status: ActivityTrackingStatus.ready,
        permissionStatus: ActivityPermissionStatus.granted,
        errorMessage: FailureMapper.from(
          TimeoutException('location timed out'),
        ).message,
      ));
    } on Exception catch (error) {
      emit(state.copyWith(
        status: ActivityTrackingStatus.ready,
        permissionStatus: ActivityPermissionStatus.denied,
        errorMessage: FailureMapper.from(error).message,
      ));
    }
  }

  Future<void> _startLocationPreview() async {
    await _positionSubscription?.cancel();
    _positionSubscription = _locationService.watchPosition().listen(
      (position) => add(LocationUpdated(position)),
      onError: (_) {},
    );
  }

  Future<void> _onPreviewStopped(
    ActivityPreviewStopped event,
    Emitter<ActivityState> emit,
  ) async {
    if (state.isSessionActive) {
      return;
    }

    await _positionSubscription?.cancel();
    _durationTimer?.cancel();
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<ActivityState> emit,
  ) async {
    if (state.permissionStatus != ActivityPermissionStatus.granted) {
      add(const ActivityStarted());
      return;
    }

    _gpsEngine.reset();
    _sessionStartTime = DateTime.now();

    unawaited(_configureGpsSession());

    if (state.currentPosition != null) {
      _gpsEngine.beginSession(
        seed: state.currentPosition!,
        accuracyMeters: state.gpsAccuracyMeters,
        timestamp: _sessionStartTime,
      );
    }

    final seededRoute = _gpsEngine.lastLocation?.polyline ?? const <LatLng>[];

    emit(state.copyWith(
      status: ActivityTrackingStatus.tracking,
      workoutSaveStatus: ActivityWorkoutSaveStatus.none,
      routePoints: seededRoute,
      duration: Duration.zero,
      distanceMeters: 0,
      currentSpeedMps: 0,
      averageSpeedMps: 0,
      maxSpeedMps: 0,
      currentAltitudeMeters: 0,
      activeCalories: 0,
      elevationGainMeters: 0,
      followUser: true,
      clearError: true,
    ));

    _startDurationTimer();
    await _startTrackingStream();
  }

  Future<void> _startTrackingStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = _locationService.watchPosition().listen(
      (position) => add(LocationUpdated(position)),
      onError: (_) {},
    );
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const DurationTicked()),
    );
  }

  void _onPauseTracking(
    PauseTracking event,
    Emitter<ActivityState> emit,
  ) {
    if (state.status != ActivityTrackingStatus.tracking) {
      return;
    }

    _gpsEngine.pauseSession();
    _durationTimer?.cancel();

    emit(state.copyWith(
      status: ActivityTrackingStatus.paused,
      duration: _gpsEngine.elapsedTime,
    ));
  }

  Future<void> _onResumeTracking(
    ResumeTracking event,
    Emitter<ActivityState> emit,
  ) async {
    if (state.status != ActivityTrackingStatus.paused) {
      return;
    }

    _gpsEngine.resumeSession();
    emit(state.copyWith(
      status: ActivityTrackingStatus.tracking,
      followUser: true,
    ));

    _startDurationTimer();
    await _startTrackingStream();
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<ActivityState> emit,
  ) async {
    final wasActiveSession =
        state.status == ActivityTrackingStatus.tracking ||
            state.status == ActivityTrackingStatus.paused;
    final lastLocation = _gpsEngine.lastLocation;
    final elapsed = _gpsEngine.elapsedTime;
    final sessionSnapshot = _SessionSnapshot(
      startTime: _sessionStartTime,
      endTime: DateTime.now(),
      duration: elapsed,
      distanceMeters: lastLocation?.totalDistance ?? 0,
      averageSpeedMps: lastLocation?.averageSpeed ?? 0,
      maxSpeedMps: lastLocation?.maxSpeed ?? 0,
      routePoints: List<LatLng>.from(lastLocation?.polyline ?? const []),
    );

    _durationTimer?.cancel();
    await _positionSubscription?.cancel();
    _gpsEngine.reset();

    if (wasActiveSession && sessionSnapshot.hasSaveableData) {
      emit(state.copyWith(
        workoutSaveStatus: ActivityWorkoutSaveStatus.saving,
      ));

      try {
        final savedWorkout = await _saveWorkout(sessionSnapshot);
        final profile = await _onboardingRepository.getUserProfile();
        final syncResult = await _gamificationRepository.syncAfterWorkout();
        final celebration = syncResult.newlyUnlocked.isNotEmpty
            ? syncResult.newlyUnlocked.first
            : null;

        emit(state.copyWith(
          status: ActivityTrackingStatus.stopped,
          workoutSaveStatus: ActivityWorkoutSaveStatus.saved,
          savedWorkoutId: savedWorkout.id,
          pendingCelebration: celebration,
          userGender: profile?.gender ?? 'male',
          routePoints: const [],
          duration: Duration.zero,
          distanceMeters: 0,
          currentSpeedMps: 0,
          averageSpeedMps: 0,
          maxSpeedMps: 0,
          currentAltitudeMeters: 0,
          activeCalories: 0,
          elevationGainMeters: 0,
          followUser: true,
          clearError: true,
        ));
        return;
      } on Exception {
        emit(state.copyWith(
          workoutSaveStatus: ActivityWorkoutSaveStatus.failed,
          errorMessage: 'Unable to save workout. Please try again.',
        ));
      }
    }

    _sessionStartTime = null;
    emit(state.copyWith(
      status: ActivityTrackingStatus.ready,
      workoutSaveStatus: ActivityWorkoutSaveStatus.none,
      routePoints: const [],
      duration: Duration.zero,
      distanceMeters: 0,
      currentSpeedMps: 0,
      averageSpeedMps: 0,
      maxSpeedMps: 0,
      currentAltitudeMeters: 0,
      activeCalories: 0,
      elevationGainMeters: 0,
      followUser: true,
      clearError: true,
    ));

    await _startLocationPreview();
  }

  Future<Workout> _saveWorkout(_SessionSnapshot snapshot) async {
    final profile = await _onboardingRepository.getUserProfile();
    final weightKg = profile?.weight ?? 70.0;
    final startTime = snapshot.startTime ?? snapshot.endTime;
    final calories = WorkoutCalorieCalculator.estimate(
      durationSeconds: snapshot.duration.inSeconds,
      distanceMeters: snapshot.distanceMeters,
      weightKg: weightKg,
    );

    final workout = Workout(
      activityType: _activityType,
      startTime: startTime,
      endTime: snapshot.endTime,
      durationInSeconds: snapshot.duration.inSeconds,
      distanceInMeters: snapshot.distanceMeters,
      averageSpeed: snapshot.averageSpeedMps,
      maxSpeed: snapshot.maxSpeedMps,
      calories: calories,
      polyline: snapshot.routePoints,
      createdAt: DateTime.now(),
    );

    return _workoutRepository.saveWorkout(workout);
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<ActivityState> emit,
  ) {
    final raw = event.position;
    final isTracking = state.status == ActivityTrackingStatus.tracking;

    if (!isTracking) {
      _gpsEngine.processPreview(raw);
      emit(state.copyWith(
        currentPosition: LatLng(raw.latitude, raw.longitude),
        gpsAccuracyMeters: raw.accuracy,
      ));
      return;
    }

    final result = _gpsEngine.process(raw);
    if (!result.wasAccepted || result.location == null) {
      return;
    }

    final location = result.location!;

    emit(state.copyWith(
      currentPosition: location.position,
      routePoints: location.polyline,
      distanceMeters: location.totalDistance,
      currentSpeedMps: location.currentSpeed,
      averageSpeedMps: location.averageSpeed,
      maxSpeedMps: location.maxSpeed,
      gpsAccuracyMeters: location.accuracy,
      duration: location.elapsedTime,
      currentAltitudeMeters: location.currentAltitudeMeters ?? 0,
      activeCalories: location.activeCalories,
      elevationGainMeters: location.elevationGainMeters,
    ));
  }

  void _onDurationTicked(DurationTicked event, Emitter<ActivityState> emit) {
    if (state.status != ActivityTrackingStatus.tracking) {
      return;
    }

    final lastLocation = _gpsEngine.lastLocation;
    emit(state.copyWith(
      duration: _gpsEngine.elapsedTime,
      averageSpeedMps: lastLocation?.averageSpeed ?? state.averageSpeedMps,
      activeCalories: lastLocation?.activeCalories ?? state.activeCalories,
      currentAltitudeMeters:
          lastLocation?.currentAltitudeMeters ?? state.currentAltitudeMeters,
      elevationGainMeters:
          lastLocation?.elevationGainMeters ?? state.elevationGainMeters,
    ));
  }

  Future<void> _configureGpsSession() async {
    final profile = await _onboardingRepository.getUserProfile();
    _gpsEngine.configureSession(
      activityType: _activityType,
      weightKg: profile?.weight ?? 70,
    );
  }

  void _onFollowUserToggled(
    FollowUserToggled event,
    Emitter<ActivityState> emit,
  ) {
    emit(state.copyWith(followUser: event.followUser));
  }

  void _onRecenterMapRequested(
    RecenterMapRequested event,
    Emitter<ActivityState> emit,
  ) {
    emit(state.copyWith(followUser: true));
  }

  void _onClearPendingCelebration(
    ClearPendingCelebration event,
    Emitter<ActivityState> emit,
  ) {
    emit(state.copyWith(clearPendingCelebration: true));
  }

  void _onClearSavedWorkoutNavigation(
    ClearSavedWorkoutNavigation event,
    Emitter<ActivityState> emit,
  ) {
    emit(state.copyWith(
      clearSavedWorkoutId: true,
      workoutSaveStatus: ActivityWorkoutSaveStatus.none,
      status: ActivityTrackingStatus.ready,
    ));
    unawaited(_startLocationPreview());
  }
}

class _SessionSnapshot {
  const _SessionSnapshot({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distanceMeters,
    required this.averageSpeedMps,
    required this.maxSpeedMps,
    required this.routePoints,
  });

  final DateTime? startTime;
  final DateTime endTime;
  final Duration duration;
  final double distanceMeters;
  final double averageSpeedMps;
  final double maxSpeedMps;
  final List<LatLng> routePoints;

  bool get hasSaveableData =>
      duration.inSeconds >= 1 || distanceMeters >= 10;
}
