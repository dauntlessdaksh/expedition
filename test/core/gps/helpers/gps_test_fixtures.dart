import 'package:expedition/core/gps/gps_engine.dart';
import 'package:expedition/core/gps/gps_engine_config.dart';
import 'package:expedition/core/gps/gps_tracking_state.dart';
import 'package:expedition/core/gps/filtered_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Shared GPS fixtures for unit tests.
class GpsTestFixtures {
  static const config = GpsEngineConfig(
    gpsLockAccuracyMeters: 12,
    gpsLockSamplesRequired: 3,
    movementConfirmationMeters: 10,
    movementConfirmationSamples: 4,
    minimumConfirmationSpeedMps: 1 / 3.6,
    maximumConfirmationSpeedMps: 25 / 3.6,
    minimumMovementMeters: 5,
    minimumUpdateInterval: Duration(seconds: 1),
    speedSmoothingWindow: 5,
    stationarySamplesRequired: 4,
    minimumMovingSpeedMps: 1 / 3.6,
    maximumSpeedMps: 12,
  );

  static const seed = LatLng(28.6139, 77.2090);

  static Position raw({
    required double lat,
    required double lng,
    required DateTime timestamp,
    double accuracy = 8,
    double speed = 25,
  }) {
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: timestamp,
      accuracy: accuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: speed,
      speedAccuracy: 0,
    );
  }

  /// Acquires GPS lock and enters [GpsTrackingState.waitingForMovement].
  static void acquireGpsLock(
    GpsEngine engine, {
    LatLng location = seed,
    DateTime? start,
  }) {
    final sessionStart = start ?? DateTime(2026, 1, 1, 10);

    engine.beginSession(
      seed: location,
      accuracyMeters: 8,
      timestamp: sessionStart,
    );

    engine.process(
      raw(
        lat: location.latitude,
        lng: location.longitude,
        timestamp: sessionStart.add(const Duration(seconds: 1)),
      ),
    );
    engine.process(
      raw(
        lat: location.latitude,
        lng: location.longitude,
        timestamp: sessionStart.add(const Duration(seconds: 2)),
      ),
    );

    expect(engine.hasGpsLock, isTrue);
    expect(engine.trackingState, GpsTrackingState.waitingForMovement);
  }

  /// Confirms movement and enters [GpsTrackingState.tracking].
  static FilteredLocation confirmMovement(
    GpsEngine engine, {
    DateTime? start,
  }) {
    var lat = seed.latitude;
    var timestamp = start ?? DateTime(2026, 1, 1, 10, 0, 3);
    FilteredLocation? last;

    for (var i = 0; i < 4; i++) {
      lat += 0.000027;
      timestamp = timestamp.add(const Duration(seconds: 1));
      final result = engine.process(
        raw(
          lat: lat,
          lng: seed.longitude,
          timestamp: timestamp,
        ),
      );
      last = result.location;
    }

    expect(engine.trackingState, GpsTrackingState.tracking);
    return last!;
  }
}
