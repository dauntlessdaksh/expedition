import 'package:expedition/core/gps/gps_engine_config.dart';
import 'package:geolocator/geolocator.dart';

/// Shared GPS fixtures for unit tests.
class GpsTestFixtures {
  static const config = GpsEngineConfig(
    minimumAccuracy: 15,
    minimumMovementMeters: 5,
    minimumUpdateInterval: Duration(seconds: 1),
    speedSmoothingWindow: 5,
    stationarySamplesRequired: 3,
    minimumMovingSpeedMps: 0.8,
    maximumSpeedMps: 12,
  );

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
}
