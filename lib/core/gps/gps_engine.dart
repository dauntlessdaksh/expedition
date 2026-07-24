import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'calculators/distance_calculator.dart';
import 'calculators/speed_calculator.dart';
import 'detectors/stationary_detector.dart';
import 'filtered_location.dart';
import 'filters/accuracy_filter.dart';
import 'filters/distance_filter.dart';
import 'filters/time_filter.dart';
import 'gps_engine_config.dart';
import 'managers/polyline_manager.dart';

/// Coordinates the full GPS filtering and metrics pipeline.
class GpsEngine {
  GpsEngine({GpsEngineConfig? config})
      : _config = config ?? GpsEngineConfig.running(),
        _accuracyFilter = const AccuracyFilter(),
        _timeFilter = TimeFilter(),
        _distanceFilter = const DistanceFilter(),
        _stationaryDetector = StationaryDetector(),
        _speedCalculator = SpeedCalculator(),
        _distanceCalculator = DistanceCalculator(),
        _polylineManager = PolylineManager();

  final GpsEngineConfig _config;
  final AccuracyFilter _accuracyFilter;
  final TimeFilter _timeFilter;
  final DistanceFilter _distanceFilter;
  final StationaryDetector _stationaryDetector;
  final SpeedCalculator _speedCalculator;
  final DistanceCalculator _distanceCalculator;
  final PolylineManager _polylineManager;

  bool _sessionActive = false;
  bool _paused = false;
  LatLng? _lastAcceptedPosition;
  DateTime? _lastAcceptedTimestamp;
  DateTime? _sessionStartedAt;
  DateTime? _elapsedSegmentStartedAt;
  Duration _accumulatedElapsed = Duration.zero;
  FilteredLocation? _lastLocation;

  GpsEngineConfig get config => _config;

  FilteredLocation? get lastLocation => _lastLocation;

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

  /// Binds a raw GPS stream to filtered location outputs.
  Stream<FilteredLocation> bind(Stream<Position> rawStream) async* {
    await for (final raw in rawStream) {
      final result = process(raw);
      if (result.location != null) {
        yield result.location!;
      }
    }
  }

  /// Processes one raw GPS fix through the full pipeline.
  GpsProcessResult process(Position raw) {
    if (!_sessionActive) {
      return const GpsProcessResult.rejected(GpsRejectReason.sessionInactive);
    }

    final timestamp = raw.timestamp;

    if (!_accuracyFilter.passes(raw, _config)) {
      return _snapshotReject(GpsRejectReason.accuracy, raw, timestamp);
    }

    if (!_timeFilter.passes(timestamp, _config)) {
      return const GpsProcessResult.rejected(GpsRejectReason.time);
    }

    _timeFilter.markProcessed(timestamp);

    final candidate = LatLng(raw.latitude, raw.longitude);

    if (_lastAcceptedPosition == null) {
      return _acceptAnchor(raw, candidate, timestamp);
    }

    final segmentMeters = _distanceFilter.segmentMeters(
      from: _lastAcceptedPosition!,
      to: candidate,
    );

    final deltaSeconds = timestamp
        .difference(_lastAcceptedTimestamp!)
        .inMilliseconds /
        1000;

    if (deltaSeconds <= 0) {
      return const GpsProcessResult.rejected(GpsRejectReason.time);
    }

    final impliedSpeedMps = segmentMeters / deltaSeconds;
    if (impliedSpeedMps > _config.maximumSpeedMps) {
      return const GpsProcessResult.rejected(GpsRejectReason.impossibleSpeed);
    }

    final isMoving = _stationaryDetector.update(
      segmentMeters: segmentMeters,
      config: _config,
    );

    if (!_distanceFilter.passesSegment(segmentMeters, _config)) {
      return _snapshotReject(GpsRejectReason.stationary, raw, timestamp);
    }

    if (!isMoving) {
      _speedCalculator.clearSamples();
      return _buildLocation(
        raw: raw,
        position: candidate,
        timestamp: timestamp,
        currentSpeed: 0,
        accepted: false,
        rejectReason: GpsRejectReason.stationary,
      );
    }

    final smoothedSpeed = _speedCalculator.recordSpeed(
      segmentMeters: segmentMeters,
      deltaSeconds: deltaSeconds,
      config: _config,
      isMoving: isMoving,
    );

    if (smoothedSpeed == null) {
      return const GpsProcessResult.rejected(GpsRejectReason.impossibleSpeed);
    }

    _distanceCalculator.applyAcceptedSegment(
      segmentMeters: segmentMeters,
      deltaSeconds: deltaSeconds,
      smoothedSpeedMps: smoothedSpeed,
      isMoving: isMoving,
      config: _config,
    );

    _polylineManager.tryAdd(candidate, _config);
    _lastAcceptedPosition = candidate;
    _lastAcceptedTimestamp = timestamp;

    return _buildLocation(
      raw: raw,
      position: candidate,
      timestamp: timestamp,
      currentSpeed: smoothedSpeed,
      accepted: true,
    );
  }

  /// Starts a new tracking session with an optional seed position.
  void beginSession({
    required LatLng seed,
    required double accuracyMeters,
    DateTime? timestamp,
  }) {
    reset();
    _sessionActive = true;
    _sessionStartedAt = timestamp ?? DateTime.now();
    _elapsedSegmentStartedAt = _sessionStartedAt;
    _lastAcceptedPosition = seed;
    _lastAcceptedTimestamp = _sessionStartedAt;
    _polylineManager.seed(seed);

    _lastLocation = FilteredLocation(
      position: seed,
      accuracy: accuracyMeters,
      currentSpeed: 0,
      averageSpeed: 0,
      totalDistance: 0,
      movingTime: Duration.zero,
      elapsedTime: Duration.zero,
      isMoving: false,
      timestamp: _sessionStartedAt!,
      polyline: _polylineManager.points,
      maxSpeed: 0,
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
    _sessionActive = false;
    _paused = false;
    _lastAcceptedPosition = null;
    _lastAcceptedTimestamp = null;
    _sessionStartedAt = null;
    _elapsedSegmentStartedAt = null;
    _accumulatedElapsed = Duration.zero;
    _lastLocation = null;

    _timeFilter.reset();
    _stationaryDetector.reset();
    _speedCalculator.reset();
    _distanceCalculator.reset();
    _polylineManager.reset();
  }

  GpsProcessResult _acceptAnchor(
    Position raw,
    LatLng candidate,
    DateTime timestamp,
  ) {
    _lastAcceptedPosition = candidate;
    _lastAcceptedTimestamp = timestamp;
    _polylineManager.seed(candidate);

    return _buildLocation(
      raw: raw,
      position: candidate,
      timestamp: timestamp,
      currentSpeed: 0,
      accepted: true,
    );
  }

  GpsProcessResult _snapshotReject(
    GpsRejectReason reason,
    Position raw,
    DateTime timestamp,
  ) {
    if (_lastLocation == null) {
      return GpsProcessResult.rejected(reason);
    }

    return GpsProcessResult(
      location: _lastLocation!.copyWith(
        elapsedTime: elapsedTime,
        timestamp: timestamp,
        accuracy: raw.accuracy,
      ),
      rejectReason: reason,
    );
  }

  GpsProcessResult _buildLocation({
    required Position raw,
    required LatLng position,
    required DateTime timestamp,
    required double currentSpeed,
    required bool accepted,
    GpsRejectReason? rejectReason,
  }) {
    final isMoving = _stationaryDetector.isMoving && currentSpeed > 0;
    final location = FilteredLocation(
      position: position,
      accuracy: raw.accuracy,
      currentSpeed: isMoving ? currentSpeed : 0,
      averageSpeed: _distanceCalculator.averageSpeedMps(),
      totalDistance: _distanceCalculator.totalDistanceMeters,
      movingTime: _distanceCalculator.movingTime,
      elapsedTime: elapsedTime,
      isMoving: isMoving,
      timestamp: timestamp,
      polyline: _polylineManager.points,
      maxSpeed: _speedCalculator.maxSpeedMps,
    );

    if (accepted) {
      _lastLocation = location;
      return GpsProcessResult.accepted(location);
    }

    _lastLocation = location.copyWith(
      currentSpeed: 0,
      isMoving: false,
    );

    return GpsProcessResult(
      location: null,
      rejectReason: rejectReason,
    );
  }
}
