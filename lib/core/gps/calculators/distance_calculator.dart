import '../gps_engine_config.dart';

/// Tracks cumulative distance and moving time from accepted GPS fixes.
class DistanceCalculator {
  double _totalDistanceMeters = 0;
  Duration _movingTime = Duration.zero;

  double get totalDistanceMeters => _totalDistanceMeters;

  Duration get movingTime => _movingTime;

  void reset() {
    _totalDistanceMeters = 0;
    _movingTime = Duration.zero;
  }

  void applyAcceptedSegment({
    required double segmentMeters,
    required double deltaSeconds,
    required double smoothedSpeedMps,
    required bool isMoving,
    required GpsEngineConfig config,
  }) {
    if (!isMoving || smoothedSpeedMps < config.minimumMovingSpeedMps) {
      return;
    }

    _totalDistanceMeters += segmentMeters;
    _movingTime += Duration(milliseconds: (deltaSeconds * 1000).round());
  }

  double averageSpeedMps() {
    if (_movingTime.inSeconds <= 0) {
      return 0;
    }

    return _totalDistanceMeters / _movingTime.inSeconds;
  }
}
