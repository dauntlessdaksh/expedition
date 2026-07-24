import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../gps_engine_config.dart';

/// Computes segment distance and validates minimum movement thresholds.
class DistanceFilter {
  const DistanceFilter();

  double segmentMeters({
    required LatLng from,
    required LatLng to,
  }) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  bool passesSegment(double segmentMeters, GpsEngineConfig config) {
    return segmentMeters >= config.minimumMovementMeters;
  }
}
