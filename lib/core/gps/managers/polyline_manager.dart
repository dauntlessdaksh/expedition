import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../gps_engine_config.dart';

/// Maintains a clean polyline from accepted GPS locations only.
class PolylineManager {
  final List<LatLng> _points = [];
  LatLng? _lastPoint;

  List<LatLng> get points => List.unmodifiable(_points);

  void reset() {
    _points.clear();
    _lastPoint = null;
  }

  void seed(LatLng point) {
    _points
      ..clear()
      ..add(point);
    _lastPoint = point;
  }

  /// Adds [point] when it is sufficiently far from the previous vertex.
  LatLng? tryAdd(LatLng point, GpsEngineConfig config) {
    if (_lastPoint == null) {
      _points.add(point);
      _lastPoint = point;
      return point;
    }

    if (_isDuplicate(_lastPoint!, point)) {
      return null;
    }

    final segment = Geolocator.distanceBetween(
      _lastPoint!.latitude,
      _lastPoint!.longitude,
      point.latitude,
      point.longitude,
    );

    if (segment < config.minimumMovementMeters) {
      return null;
    }

    _points.add(point);
    _lastPoint = point;
    return point;
  }

  bool _isDuplicate(LatLng a, LatLng b) {
    return a.latitude == b.latitude && a.longitude == b.longitude;
  }
}
