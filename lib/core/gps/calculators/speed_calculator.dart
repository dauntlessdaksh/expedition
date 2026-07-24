import 'dart:collection';

import '../gps_engine_config.dart';

/// Calculates and smooths speed from accepted GPS segments.
///
/// Never reads [Position.speed] — only distance / time between fixes.
class SpeedCalculator {
  final Queue<double> _samples = Queue<double>();
  double _maxSpeedMps = 0;

  double get maxSpeedMps => _maxSpeedMps;

  void reset() {
    _samples.clear();
    _maxSpeedMps = 0;
  }

  /// Returns null when speed exceeds the configured activity maximum.
  double? recordSpeed({
    required double segmentMeters,
    required double deltaSeconds,
    required GpsEngineConfig config,
    required bool isMoving,
  }) {
    if (!isMoving || deltaSeconds <= 0) {
      return 0;
    }

    final instantSpeed = segmentMeters / deltaSeconds;
    if (instantSpeed > config.maximumSpeedMps) {
      return null;
    }

    _pushSample(instantSpeed, config.speedSmoothingWindow);

    if (instantSpeed > _maxSpeedMps) {
      _maxSpeedMps = instantSpeed;
    }

    return smoothedSpeed();
  }

  double smoothedSpeed() {
    if (_samples.isEmpty) {
      return 0;
    }

    final total = _samples.fold<double>(0, (sum, value) => sum + value);
    return total / _samples.length;
  }

  void clearSamples() {
    _samples.clear();
  }

  void _pushSample(double speedMps, int windowSize) {
    _samples.addLast(speedMps);
    while (_samples.length > windowSize) {
      _samples.removeFirst();
    }
  }
}
