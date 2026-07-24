import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/services/location_service.dart';
import '../../data/utils/activity_metrics_tracker.dart';

part 'activity_event.dart';
part 'activity_state.dart';

/// Manages live GPS activity tracking state in memory.
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc({required LocationService locationService})
      : _locationService = locationService,
        super(const ActivityState()) {
    on<ActivityStarted>(_onStarted);
    on<StartTracking>(_onStartTracking);
    on<PauseTracking>(_onPauseTracking);
    on<ResumeTracking>(_onResumeTracking);
    on<StopTracking>(_onStopTracking);
    on<LocationUpdated>(_onLocationUpdated);
    on<DurationTicked>(_onDurationTicked);
    on<FollowUserToggled>(_onFollowUserToggled);
    on<RecenterMapRequested>(_onRecenterMapRequested);
  }

  final LocationService _locationService;
  final ActivityMetricsTracker _metrics = ActivityMetricsTracker();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _durationTimer;

  Duration _accumulatedDuration = Duration.zero;
  DateTime? _segmentStartTime;

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
      clearError: true,
    ));

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(
        status: ActivityTrackingStatus.ready,
        permissionStatus: ActivityPermissionStatus.serviceDisabled,
        errorMessage: 'Location services are disabled.',
      ));
      return;
    }

    final granted = await _locationService.ensurePermission();
    if (!granted) {
      emit(state.copyWith(
        status: ActivityTrackingStatus.ready,
        permissionStatus: ActivityPermissionStatus.denied,
        errorMessage: 'Location permission is required to track activities.',
      ));
      return;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        emit(state.copyWith(
          status: ActivityTrackingStatus.ready,
          permissionStatus: ActivityPermissionStatus.denied,
          errorMessage: 'Unable to determine your current location.',
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
    } on Exception {
      emit(state.copyWith(
        status: ActivityTrackingStatus.ready,
        permissionStatus: ActivityPermissionStatus.denied,
        errorMessage: 'Unable to determine your current location.',
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

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<ActivityState> emit,
  ) async {
    if (state.permissionStatus != ActivityPermissionStatus.granted) {
      add(const ActivityStarted());
      return;
    }

    _metrics.reset();
    _accumulatedDuration = Duration.zero;
    _segmentStartTime = DateTime.now();

    final initialPoints = state.currentPosition == null
        ? <LatLng>[]
        : [state.currentPosition!];

    emit(state.copyWith(
      status: ActivityTrackingStatus.tracking,
      routePoints: initialPoints,
      duration: Duration.zero,
      distanceMeters: 0,
      currentSpeedMps: 0,
      averageSpeedMps: 0,
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

    _accumulatedDuration = _currentElapsedDuration();
    _segmentStartTime = null;
    _durationTimer?.cancel();

    emit(state.copyWith(status: ActivityTrackingStatus.paused));
  }

  Future<void> _onResumeTracking(
    ResumeTracking event,
    Emitter<ActivityState> emit,
  ) async {
    if (state.status != ActivityTrackingStatus.paused) {
      return;
    }

    _segmentStartTime = DateTime.now();
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
    _durationTimer?.cancel();
    await _positionSubscription?.cancel();

    _metrics.reset();
    _accumulatedDuration = Duration.zero;
    _segmentStartTime = null;

    emit(state.copyWith(
      status: ActivityTrackingStatus.ready,
      routePoints: const [],
      duration: Duration.zero,
      distanceMeters: 0,
      currentSpeedMps: 0,
      averageSpeedMps: 0,
      followUser: true,
      clearError: true,
    ));

    await _startLocationPreview();
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<ActivityState> emit,
  ) {
    final position = event.position;
    final latLng = LatLng(position.latitude, position.longitude);
    final isTracking = state.status == ActivityTrackingStatus.tracking;

    var routePoints = state.routePoints;
    var distanceMeters = state.distanceMeters;
    var currentSpeedMps = state.currentSpeedMps;
    var averageSpeedMps = state.averageSpeedMps;

    if (isTracking) {
      _metrics.recordPosition(position);
      distanceMeters = _metrics.distanceMeters;
      currentSpeedMps = _metrics.currentSpeedMps(position);
      averageSpeedMps = _metrics.averageSpeedMps(_currentElapsedDuration());

      final lastPoint = routePoints.isEmpty ? null : routePoints.last;
      if (lastPoint == null ||
          lastPoint.latitude != latLng.latitude ||
          lastPoint.longitude != latLng.longitude) {
        routePoints = [...routePoints, latLng];
      }
    }

    emit(state.copyWith(
      currentPosition: latLng,
      routePoints: routePoints,
      distanceMeters: distanceMeters,
      currentSpeedMps: currentSpeedMps,
      averageSpeedMps: averageSpeedMps,
      gpsAccuracyMeters: position.accuracy,
    ));
  }

  void _onDurationTicked(DurationTicked event, Emitter<ActivityState> emit) {
    if (state.status != ActivityTrackingStatus.tracking) {
      return;
    }

    final elapsed = _currentElapsedDuration();
    emit(state.copyWith(
      duration: elapsed,
      averageSpeedMps: _metrics.averageSpeedMps(elapsed),
    ));
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

  Duration _currentElapsedDuration() {
    if (_segmentStartTime == null) {
      return _accumulatedDuration;
    }

    return _accumulatedDuration +
        DateTime.now().difference(_segmentStartTime!);
  }
}
