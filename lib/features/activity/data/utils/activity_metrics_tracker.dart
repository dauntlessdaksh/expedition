import 'package:geolocator/geolocator.dart';

/// In-memory distance and speed calculations for a live activity session.
class ActivityMetricsTracker {
  double distanceMeters = 0;
  Position? _lastRecordedPosition;
  DateTime? _lastRecordedTime;

  void reset() {
    distanceMeters = 0;
    _lastRecordedPosition = null;
    _lastRecordedTime = null;
  }

  void recordPosition(Position position) {
    if (_lastRecordedPosition != null) {
      final segment = Geolocator.distanceBetween(
        _lastRecordedPosition!.latitude,
        _lastRecordedPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      if (segment >= 0.5) {
        distanceMeters += segment;
      }
    }

    _lastRecordedPosition = position;
    _lastRecordedTime = DateTime.now();
  }

  double currentSpeedMps(Position position) {
    if (position.speed >= 0) {
      return position.speed;
    }

    if (_lastRecordedPosition == null || _lastRecordedTime == null) {
      return 0;
    }

    final elapsedSeconds =
        DateTime.now().difference(_lastRecordedTime!).inMilliseconds / 1000;
    if (elapsedSeconds <= 0) {
      return 0;
    }

    final segment = Geolocator.distanceBetween(
      _lastRecordedPosition!.latitude,
      _lastRecordedPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    return segment / elapsedSeconds;
  }

  double averageSpeedMps(Duration elapsed) {
    final seconds = elapsed.inSeconds;
    if (seconds <= 0) {
      return 0;
    }

    return distanceMeters / seconds;
  }
}
