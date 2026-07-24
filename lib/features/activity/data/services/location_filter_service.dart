import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/filtered_location_update.dart';
import 'location_filter_config.dart';

/// Production-grade GPS filtering pipeline for live activity tracking.
///
/// Raw fixes enter the pipeline; only accepted fixes update distance, speed,
/// moving time, and polyline vertices.
class LocationFilterService {
  LocationFilterService({LocationFilterConfig? config})
      : _config = config ?? const LocationFilterConfig();

  final LocationFilterConfig _config;

  AcceptedLocationFix? _lastAccepted;
  LatLng? _lastPolylinePoint;
  DateTime? _lastRawProcessedAt;

  final Queue<double> _speedSamples = Queue<double>();

  LocationFilterMetrics _metrics = const LocationFilterMetrics();

  LocationFilterConfig get config => _config;

  LocationFilterMetrics get metrics => _metrics;

  /// Clears all session state.
  void reset() {
    _lastAccepted = null;
    _lastPolylinePoint = null;
    _lastRawProcessedAt = null;
    _speedSamples.clear();
    _metrics = const LocationFilterMetrics();
  }

  /// Seeds the filter with the user's position when a workout begins.
  void seed({
    required LatLng position,
    required double accuracyMeters,
    DateTime? timestamp,
  }) {
    final fixTime = timestamp ?? DateTime.now();
    final seeded = Position(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: fixTime,
      accuracy: accuracyMeters,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    _lastAccepted = AcceptedLocationFix(
      position: seeded,
      timestamp: fixTime,
      instantSpeedMps: 0,
      smoothedSpeedMps: 0,
    );
    _lastPolylinePoint = position;
    _metrics = LocationFilterMetrics(
      routePoints: [position],
    );
  }

  /// Processes a raw GPS fix and returns filtered metrics.
  ///
  /// When [tracking] is false, raw fixes are returned without mutating metrics.
  FilteredLocationUpdate processRaw(
    Position raw, {
    required bool tracking,
  }) {
    if (!tracking) {
      return FilteredLocationUpdate(
        rawPosition: raw,
        metrics: _metrics,
      );
    }

    final now = _positionTimestamp(raw);

    if (_lastRawProcessedAt != null) {
      final sinceLastRaw = now.difference(_lastRawProcessedAt!);
      if (sinceLastRaw < _config.minUpdateInterval) {
        return FilteredLocationUpdate(
          rawPosition: raw,
          metrics: _metrics,
          rejectReason: LocationFilterRejectReason.updateTooSoon,
        );
      }
    }

    _lastRawProcessedAt = now;

    if (raw.accuracy > _config.maxAccuracyMeters) {
      return FilteredLocationUpdate(
        rawPosition: raw,
        metrics: _metrics,
        rejectReason: LocationFilterRejectReason.accuracyTooLow,
      );
    }

    if (_lastAccepted == null) {
      return _acceptAnchor(raw, now);
    }

    final segmentMeters = Geolocator.distanceBetween(
      _lastAccepted!.position.latitude,
      _lastAccepted!.position.longitude,
      raw.latitude,
      raw.longitude,
    );

    final elapsedSeconds =
        now.difference(_lastAccepted!.timestamp).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      return FilteredLocationUpdate(
        rawPosition: raw,
        metrics: _metrics,
        rejectReason: LocationFilterRejectReason.updateTooSoon,
      );
    }

    final impliedSpeedMps = segmentMeters / elapsedSeconds;
    if (impliedSpeedMps > _config.maxPlausibleSpeedMps) {
      return FilteredLocationUpdate(
        rawPosition: raw,
        metrics: _metrics,
        rejectReason: LocationFilterRejectReason.impossibleJump,
      );
    }

    if (segmentMeters < _config.minMovementMeters) {
      return FilteredLocationUpdate(
        rawPosition: raw,
        metrics: _metrics,
        rejectReason: LocationFilterRejectReason.stationary,
      );
    }

    return _acceptMovement(
      raw: raw,
      timestamp: now,
      segmentMeters: segmentMeters,
      elapsedSeconds: elapsedSeconds,
      instantSpeedMps: impliedSpeedMps,
    );
  }

  FilteredLocationUpdate _acceptAnchor(Position raw, DateTime timestamp) {
    final accepted = AcceptedLocationFix(
      position: raw,
      timestamp: timestamp,
      instantSpeedMps: 0,
      smoothedSpeedMps: 0,
    );

    _lastAccepted = accepted;
    _lastPolylinePoint = accepted.latLng;
    _metrics = LocationFilterMetrics(
      routePoints: [accepted.latLng],
    );

    return FilteredLocationUpdate(
      rawPosition: raw,
      accepted: accepted,
      metrics: _metrics,
      polylinePointAdded: accepted.latLng,
    );
  }

  FilteredLocationUpdate _acceptMovement({
    required Position raw,
    required DateTime timestamp,
    required double segmentMeters,
    required double elapsedSeconds,
    required double instantSpeedMps,
  }) {
    _pushSpeedSample(instantSpeedMps);
    final smoothedSpeed = _smoothedSpeed();

    final nextDistance = _metrics.totalDistanceMeters + segmentMeters;
    final nextMovingTime = smoothedSpeed >= _config.movingSpeedThresholdMps
        ? _metrics.movingTime + Duration(milliseconds: (elapsedSeconds * 1000).round())
        : _metrics.movingTime;

    final nextAverageSpeed = nextMovingTime.inSeconds <= 0
        ? 0.0
        : nextDistance / nextMovingTime.inSeconds;

    final nextMaxSpeed = instantSpeedMps > _metrics.maxSpeedMps
        ? instantSpeedMps
        : _metrics.maxSpeedMps;

    LatLng? polylinePointAdded;
    final routePoints = List<LatLng>.from(_metrics.routePoints);
    final candidate = LatLng(raw.latitude, raw.longitude);

    if (_lastPolylinePoint == null) {
      routePoints.add(candidate);
      _lastPolylinePoint = candidate;
      polylinePointAdded = candidate;
    } else {
      final polylineSegment = Geolocator.distanceBetween(
        _lastPolylinePoint!.latitude,
        _lastPolylinePoint!.longitude,
        candidate.latitude,
        candidate.longitude,
      );

      if (polylineSegment >= _config.minPolylineSegmentMeters) {
        routePoints.add(candidate);
        _lastPolylinePoint = candidate;
        polylinePointAdded = candidate;
      }
    }

    final accepted = AcceptedLocationFix(
      position: raw,
      timestamp: timestamp,
      instantSpeedMps: instantSpeedMps,
      smoothedSpeedMps: smoothedSpeed,
    );

    _lastAccepted = accepted;
    _metrics = LocationFilterMetrics(
      totalDistanceMeters: nextDistance,
      movingTime: nextMovingTime,
      currentSpeedMps: smoothedSpeed,
      averageSpeedMps: nextAverageSpeed,
      maxSpeedMps: nextMaxSpeed,
      routePoints: routePoints,
    );

    return FilteredLocationUpdate(
      rawPosition: raw,
      accepted: accepted,
      metrics: _metrics,
      polylinePointAdded: polylinePointAdded,
    );
  }

  void _pushSpeedSample(double speedMps) {
    _speedSamples.addLast(speedMps);
    while (_speedSamples.length > _config.speedSmoothingWindowSize) {
      _speedSamples.removeFirst();
    }
  }

  double _smoothedSpeed() {
    if (_speedSamples.isEmpty) {
      return 0;
    }

    final total = _speedSamples.fold<double>(0, (sum, value) => sum + value);
    return total / _speedSamples.length;
  }

  DateTime _positionTimestamp(Position position) {
    return position.timestamp;
  }
}
