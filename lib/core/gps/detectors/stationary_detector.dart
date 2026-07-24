import '../gps_engine_config.dart';

/// Determines whether the user is moving with hysteresis to avoid flicker.
class StationaryDetector {
  int _consecutiveLowMovement = 0;
  int _consecutiveHighMovement = 0;
  bool _isMoving = false;

  bool get isMoving => _isMoving;

  void reset() {
    _consecutiveLowMovement = 0;
    _consecutiveHighMovement = 0;
    _isMoving = false;
  }

  /// Updates movement state from a segment distance observation.
  ///
  /// Returns the current moving flag after hysteresis is applied.
  bool update({
    required double segmentMeters,
    required GpsEngineConfig config,
  }) {
    if (segmentMeters < config.minimumMovementMeters) {
      _consecutiveLowMovement++;
      _consecutiveHighMovement = 0;

      if (_consecutiveLowMovement >= config.stationarySamplesRequired) {
        _isMoving = false;
      }

      return _isMoving;
    }

    _consecutiveHighMovement++;
    _consecutiveLowMovement = 0;

    if (_consecutiveHighMovement >= 2) {
      _isMoving = true;
    }

    return _isMoving;
  }
}
