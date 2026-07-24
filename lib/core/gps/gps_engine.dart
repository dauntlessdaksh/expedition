import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'calculators/calorie_calculator.dart';
import 'calculators/distance_calculator.dart';
import 'calculators/speed_calculator.dart';
import 'filtered_location.dart';
import 'filters/distance_filter.dart';
import 'filters/time_filter.dart';
import 'gps_engine_config.dart';
import 'gps_tracking_state.dart';
import 'managers/polyline_manager.dart';
import 'trackers/elevation_tracker.dart';

/// Outdoor-only GPS engine with a professional state machine pipeline.
class GpsEngine {
  GpsEngine({GpsEngineConfig? config})
      : _config = config ?? GpsEngineConfig.running(),
        _timeFilter = TimeFilter(),
        _distanceFilter = const DistanceFilter(),
        _speedCalculator = SpeedCalculator(),
        _distanceCalculator = DistanceCalculator(),
        _polylineManager = PolylineManager(),
        _calorieCalculator = CalorieCalculator(),
        _elevationTracker = ElevationTracker();

  final GpsEngineConfig _config;
  final TimeFilter _timeFilter;
  final DistanceFilter _distanceFilter;
  final SpeedCalculator _speedCalculator;
  final DistanceCalculator _distanceCalculator;
  final PolylineManager _polylineManager;
  final CalorieCalculator _calorieCalculator;
  final ElevationTracker _elevationTracker;

  GpsTrackingState _state = GpsTrackingState.waitingForGpsLock;
  bool _sessionActive = false;
  bool _paused = false;
  bool _hasGpsLock = false;

  int _gpsLockSamples = 0;
  int _movementConfirmSamples = 0;
  int _consecutiveStationarySamples = 0;

  LatLng? _movementOrigin;
  LatLng? _lastFixPosition;
  DateTime? _lastFixTimestamp;

  double _pendingConfirmedMeters = 0;
  Duration _pendingConfirmedTime = Duration.zero;

  DateTime? _elapsedSegmentStartedAt;
  Duration _accumulatedElapsed = Duration.zero;
  FilteredLocation? _lastLocation;

  GpsEngineConfig get config => _config;

  GpsTrackingState get trackingState => _state;

  bool get hasGpsLock => _hasGpsLock;

  FilteredLocation? get lastLocation => _lastLocation;

  void configureSession({
    required String activityType,
    double weightKg = 70,
  }) {
    _calorieCalculator.configure(
      activityType: activityType,
      weightKg: weightKg,
    );
  }

  Duration get elapsedTime {
    if (!_sessionActive) {
      return Duration.zero;
    }

    if (_paused || _elapsedSegmentStartedAt == null) {
      return _accumulatedElapsed;
    }

    return _accumulatedElapsed +
        DateTime.now().difference(_elapsedSegmentStartedAt!);
  }

  /// Builds GPS lock from preview fixes before a workout session starts.
  void processPreview(Position raw) {
    if (_sessionActive) {
      return;
    }

    _registerGpsLockSample(raw.accuracy);
  }

  /// Binds a raw GPS stream to filtered location outputs.
  Stream<FilteredLocation> bind(Stream<Position> rawStream) async* {
    await for (final raw in rawStream) {
      final result = process(raw);
      if (result.location != null) {
        yield result.location!;
      }
    }
  }

  /// Processes one raw GPS fix through the outdoor tracking state machine.
  GpsProcessResult process(Position raw) {
    if (!_sessionActive) {
      return const GpsProcessResult.rejected(GpsRejectReason.sessionInactive);
    }

    final timestamp = raw.timestamp;
    final candidate = LatLng(raw.latitude, raw.longitude);

    if (!_timeFilter.passes(timestamp, _config)) {
      return const GpsProcessResult.rejected(GpsRejectReason.time);
    }

    _timeFilter.markProcessed(timestamp);

    if (_lastFixPosition == null) {
      _lastFixPosition = candidate;
      _lastFixTimestamp = timestamp;
      return GpsProcessResult.accepted(
        _buildSnapshot(
          raw: raw,
          position: candidate,
          timestamp: timestamp,
          currentSpeed: 0,
        ),
      );
    }

    final deltaSeconds = timestamp
            .difference(_lastFixTimestamp!)
            .inMilliseconds /
        1000;

    if (deltaSeconds <= 0) {
      return const GpsProcessResult.rejected(GpsRejectReason.time);
    }

    final segmentMeters = _distanceFilter.segmentMeters(
      from: _lastFixPosition!,
      to: candidate,
    );

    final impliedSpeedMps = segmentMeters / deltaSeconds;

    _lastFixPosition = candidate;
    _lastFixTimestamp = timestamp;

    return switch (_state) {
      GpsTrackingState.waitingForGpsLock =>
        _processWaitingForGpsLock(raw, candidate, timestamp),
      GpsTrackingState.waitingForMovement => _processWaitingForMovement(
          raw,
          candidate,
          timestamp,
          segmentMeters: segmentMeters,
          deltaSeconds: deltaSeconds,
          impliedSpeedMps: impliedSpeedMps,
        ),
      GpsTrackingState.tracking => _processTracking(
          raw,
          candidate,
          timestamp,
          segmentMeters: segmentMeters,
          deltaSeconds: deltaSeconds,
          impliedSpeedMps: impliedSpeedMps,
        ),
      GpsTrackingState.possibleStop => _processPossibleStop(
          raw,
          candidate,
          timestamp,
          segmentMeters: segmentMeters,
          deltaSeconds: deltaSeconds,
          impliedSpeedMps: impliedSpeedMps,
        ),
      GpsTrackingState.stopped => _processStopped(
          raw,
          candidate,
          timestamp,
          segmentMeters: segmentMeters,
          deltaSeconds: deltaSeconds,
          impliedSpeedMps: impliedSpeedMps,
        ),
    };
  }

  /// Starts a workout session. Elapsed time begins immediately.
  void beginSession({
    required LatLng seed,
    required double accuracyMeters,
    DateTime? timestamp,
  }) {
    final preservedLock = _hasGpsLock;
    _resetSessionMetrics();

    _sessionActive = true;
    _elapsedSegmentStartedAt = timestamp ?? DateTime.now();
    _lastFixPosition = seed;
    _lastFixTimestamp = _elapsedSegmentStartedAt;

    if (preservedLock) {
      _hasGpsLock = true;
      _gpsLockSamples = _config.gpsLockSamplesRequired;
    } else {
      _registerGpsLockSample(accuracyMeters);
    }

    if (_hasGpsLock) {
      _enterWaitingForMovement(seed);
    } else {
      _state = GpsTrackingState.waitingForGpsLock;
    }

    _lastLocation = _buildSnapshot(
      raw: _syntheticPosition(seed, accuracyMeters, _lastFixTimestamp!),
      position: seed,
      timestamp: _lastFixTimestamp!,
      currentSpeed: 0,
    );
  }

  void pauseSession() {
    if (!_sessionActive || _paused) {
      return;
    }

    _accumulatedElapsed = elapsedTime;
    _paused = true;
    _elapsedSegmentStartedAt = null;
  }

  void resumeSession() {
    if (!_sessionActive || !_paused) {
      return;
    }

    _paused = false;
    _elapsedSegmentStartedAt = DateTime.now();
  }

  void endSession() {
    _sessionActive = false;
    _paused = false;
  }

  void reset() {
    _resetSessionMetrics();
    _hasGpsLock = false;
    _gpsLockSamples = 0;
  }

  void _resetSessionMetrics() {
    _sessionActive = false;
    _paused = false;
    _state = GpsTrackingState.waitingForGpsLock;
    _movementConfirmSamples = 0;
    _consecutiveStationarySamples = 0;
    _movementOrigin = null;
    _lastFixPosition = null;
    _lastFixTimestamp = null;
    _pendingConfirmedMeters = 0;
    _pendingConfirmedTime = Duration.zero;
    _elapsedSegmentStartedAt = null;
    _accumulatedElapsed = Duration.zero;
    _lastLocation = null;

    _timeFilter.reset();
    _speedCalculator.reset();
    _distanceCalculator.reset();
    _polylineManager.reset();
    _calorieCalculator.reset();
    _elevationTracker.reset();
  }

  GpsProcessResult _processWaitingForGpsLock(
    Position raw,
    LatLng candidate,
    DateTime timestamp,
  ) {
    _registerGpsLockSample(raw.accuracy);

    if (_hasGpsLock) {
      _enterWaitingForMovement(candidate);
    }

    return GpsProcessResult.accepted(
      _buildSnapshot(
        raw: raw,
        position: candidate,
        timestamp: timestamp,
        currentSpeed: 0,
      ),
    );
  }

  GpsProcessResult _processWaitingForMovement(
    Position raw,
    LatLng candidate,
    DateTime timestamp, {
    required double segmentMeters,
    required double deltaSeconds,
    required double impliedSpeedMps,
  }) {
    if (!_isAccurateFix(raw.accuracy)) {
      _movementConfirmSamples = 0;
      _pendingConfirmedMeters = 0;
      _pendingConfirmedTime = Duration.zero;
      return GpsProcessResult.accepted(
        _buildSnapshot(
          raw: raw,
          position: candidate,
          timestamp: timestamp,
          currentSpeed: 0,
        ),
      );
    }

    if (_isValidConfirmationSpeed(impliedSpeedMps)) {
      _movementConfirmSamples++;
      _pendingConfirmedMeters += segmentMeters;
      _pendingConfirmedTime +=
          Duration(milliseconds: (deltaSeconds * 1000).round());
    } else {
      _movementConfirmSamples = 0;
      _pendingConfirmedMeters = 0;
      _pendingConfirmedTime = Duration.zero;
    }

    if (_movementOrigin != null &&
        _movementConfirmSamples >= _config.movementConfirmationSamples &&
        _netDisplacementMeters(_movementOrigin!, candidate) >=
            _config.movementConfirmationMeters) {
      _enterTracking(candidate);
    }

    return GpsProcessResult.accepted(
      _buildSnapshot(
        raw: raw,
        position: candidate,
        timestamp: timestamp,
        currentSpeed: 0,
      ),
    );
  }

  GpsProcessResult _processTracking(
    Position raw,
    LatLng candidate,
    DateTime timestamp, {
    required double segmentMeters,
    required double deltaSeconds,
    required double impliedSpeedMps,
  }) {
    if (!_isAccurateFix(raw.accuracy)) {
      return GpsProcessResult.accepted(
        _buildSnapshot(
          raw: raw,
          position: candidate,
          timestamp: timestamp,
          currentSpeed: 0,
        ),
      );
    }

    if (impliedSpeedMps > _config.maximumSpeedMps) {
      return const GpsProcessResult.rejected(GpsRejectReason.impossibleSpeed);
    }

    if (segmentMeters < _config.minimumMovementMeters) {
      _state = GpsTrackingState.possibleStop;
      _consecutiveStationarySamples = 1;
      _speedCalculator.clearSamples();

      return GpsProcessResult.accepted(
        _buildSnapshot(
          raw: raw,
          position: candidate,
          timestamp: timestamp,
          currentSpeed: 0,
        ),
      );
    }

    final smoothedSpeed = _speedCalculator.recordSpeed(
      segmentMeters: segmentMeters,
      deltaSeconds: deltaSeconds,
      config: _config,
      isMoving: true,
    );

    if (smoothedSpeed == null) {
      return const GpsProcessResult.rejected(GpsRejectReason.impossibleSpeed);
    }

    _distanceCalculator.applyAcceptedSegment(
      segmentMeters: segmentMeters,
      deltaSeconds: deltaSeconds,
      smoothedSpeedMps: smoothedSpeed,
      isMoving: true,
      config: _config,
    );

    _polylineManager.tryAdd(candidate, _config);
    _consecutiveStationarySamples = 0;
    _elevationTracker.process(raw.altitude);
    _calorieCalculator.applyMovingSegment(
      deltaSeconds: deltaSeconds,
      currentSpeedMps: smoothedSpeed,
      isMoving: true,
      gpsMovementAccepted: true,
    );

    return GpsProcessResult.accepted(
      _buildSnapshot(
        raw: raw,
        position: candidate,
        timestamp: timestamp,
        currentSpeed: smoothedSpeed,
      ),
    );
  }

  GpsProcessResult _processPossibleStop(
    Position raw,
    LatLng candidate,
    DateTime timestamp, {
    required double segmentMeters,
    required double deltaSeconds,
    required double impliedSpeedMps,
  }) {
    if (!_isAccurateFix(raw.accuracy)) {
      return GpsProcessResult.accepted(
        _buildSnapshot(
          raw: raw,
          position: candidate,
          timestamp: timestamp,
          currentSpeed: 0,
        ),
      );
    }

    if (segmentMeters >= _config.minimumMovementMeters &&
        _isValidConfirmationSpeed(impliedSpeedMps)) {
      _state = GpsTrackingState.tracking;
      _consecutiveStationarySamples = 0;

      return _processTracking(
        raw,
        candidate,
        timestamp,
        segmentMeters: segmentMeters,
        deltaSeconds: deltaSeconds,
        impliedSpeedMps: impliedSpeedMps,
      );
    }

    _consecutiveStationarySamples++;

    if (_consecutiveStationarySamples >= _config.stationarySamplesRequired) {
      _enterStopped(candidate);
    }

    return GpsProcessResult.accepted(
      _buildSnapshot(
        raw: raw,
        position: candidate,
        timestamp: timestamp,
        currentSpeed: 0,
      ),
    );
  }

  GpsProcessResult _processStopped(
    Position raw,
    LatLng candidate,
    DateTime timestamp, {
    required double segmentMeters,
    required double deltaSeconds,
    required double impliedSpeedMps,
  }) {
    if (!_isAccurateFix(raw.accuracy)) {
      _movementConfirmSamples = 0;
      _pendingConfirmedMeters = 0;
      _pendingConfirmedTime = Duration.zero;
      return GpsProcessResult.accepted(
        _buildSnapshot(
          raw: raw,
          position: candidate,
          timestamp: timestamp,
          currentSpeed: 0,
        ),
      );
    }

    if (_isValidConfirmationSpeed(impliedSpeedMps)) {
      _movementConfirmSamples++;
      _pendingConfirmedMeters += segmentMeters;
      _pendingConfirmedTime +=
          Duration(milliseconds: (deltaSeconds * 1000).round());
    } else {
      _movementConfirmSamples = 0;
      _pendingConfirmedMeters = 0;
      _pendingConfirmedTime = Duration.zero;
    }

    if (_movementOrigin != null &&
        _movementConfirmSamples >= _config.movementConfirmationSamples &&
        _netDisplacementMeters(_movementOrigin!, candidate) >=
            _config.movementConfirmationMeters) {
      _enterTracking(candidate);
    }

    return GpsProcessResult.accepted(
      _buildSnapshot(
        raw: raw,
        position: candidate,
        timestamp: timestamp,
        currentSpeed: 0,
      ),
    );
  }

  void _registerGpsLockSample(double accuracyMeters) {
    if (_isAccurateFix(accuracyMeters)) {
      _gpsLockSamples++;
    } else {
      _gpsLockSamples = 0;
    }

    if (_gpsLockSamples >= _config.gpsLockSamplesRequired) {
      _hasGpsLock = true;
    }
  }

  void _enterWaitingForMovement(LatLng origin) {
    _state = GpsTrackingState.waitingForMovement;
    _movementOrigin = origin;
    _movementConfirmSamples = 0;
    _consecutiveStationarySamples = 0;
    _pendingConfirmedMeters = 0;
    _pendingConfirmedTime = Duration.zero;
    _speedCalculator.clearSamples();
  }

  void _enterTracking(LatLng candidate) {
    _state = GpsTrackingState.tracking;
    _movementConfirmSamples = 0;
    _consecutiveStationarySamples = 0;

    final origin = _movementOrigin ?? candidate;
    _polylineManager.seed(origin);

    if (_pendingConfirmedMeters > 0 && _pendingConfirmedTime.inSeconds > 0) {
      final averageSpeed =
          _pendingConfirmedMeters / _pendingConfirmedTime.inSeconds;

      _speedCalculator.recordSpeed(
        segmentMeters: _pendingConfirmedMeters,
        deltaSeconds: _pendingConfirmedTime.inSeconds.toDouble(),
        config: _config,
        isMoving: true,
      );

      _distanceCalculator.applyAcceptedSegment(
        segmentMeters: _pendingConfirmedMeters,
        deltaSeconds: _pendingConfirmedTime.inSeconds.toDouble(),
        smoothedSpeedMps: averageSpeed,
        isMoving: true,
        config: _config,
      );

      _calorieCalculator.applyMovingSegment(
        deltaSeconds: _pendingConfirmedTime.inSeconds.toDouble(),
        currentSpeedMps: averageSpeed,
        isMoving: true,
        gpsMovementAccepted: true,
      );
    }

    _polylineManager.tryAdd(candidate, _config);
    _pendingConfirmedMeters = 0;
    _pendingConfirmedTime = Duration.zero;
    _movementOrigin = null;
  }

  void _enterStopped(LatLng origin) {
    _state = GpsTrackingState.stopped;
    _movementOrigin = origin;
    _movementConfirmSamples = 0;
    _pendingConfirmedMeters = 0;
    _pendingConfirmedTime = Duration.zero;
    _speedCalculator.clearSamples();
  }

  bool _isAccurateFix(double accuracyMeters) {
    return accuracyMeters <= _config.gpsLockAccuracyMeters;
  }

  bool _isValidConfirmationSpeed(double speedMps) {
    return speedMps >= _config.minimumConfirmationSpeedMps &&
        speedMps <= _config.maximumConfirmationSpeedMps;
  }

  double _netDisplacementMeters(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  FilteredLocation _buildSnapshot({
    required Position raw,
    required LatLng position,
    required DateTime timestamp,
    required double currentSpeed,
  }) {
    final isTracking = _state == GpsTrackingState.tracking;
    final location = FilteredLocation(
      position: position,
      accuracy: raw.accuracy,
      currentSpeed: isTracking ? currentSpeed : 0,
      averageSpeed: _distanceCalculator.averageSpeedMps(),
      totalDistance: _distanceCalculator.totalDistanceMeters,
      movingTime: _distanceCalculator.movingTime,
      elapsedTime: elapsedTime,
      isMoving: isTracking && currentSpeed > 0,
      trackingState: _state,
      hasGpsLock: _hasGpsLock,
      timestamp: timestamp,
      polyline: _polylineManager.points,
      maxSpeed: _speedCalculator.maxSpeedMps,
      activeCalories: _calorieCalculator.activeCaloriesRounded,
      currentAltitudeMeters: _elevationTracker.currentAltitudeMeters,
      elevationGainMeters: _elevationTracker.elevationGainMeters,
    );

    _lastLocation = location;
    return location;
  }

  Position _syntheticPosition(
    LatLng point,
    double accuracy,
    DateTime timestamp,
  ) {
    return Position(
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: timestamp,
      accuracy: accuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
