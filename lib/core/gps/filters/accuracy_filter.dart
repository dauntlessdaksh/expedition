import 'package:geolocator/geolocator.dart';

import '../gps_engine_config.dart';

/// Rejects GPS fixes with poor horizontal accuracy.
class AccuracyFilter {
  const AccuracyFilter();

  bool passes(Position position, GpsEngineConfig config) {
    return position.accuracy <= config.gpsLockAccuracyMeters;
  }
}
