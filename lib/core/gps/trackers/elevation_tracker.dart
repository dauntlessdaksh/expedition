/// Tracks smoothed altitude and cumulative elevation gain/loss.
class ElevationTracker {
  ElevationTracker({
    this.noiseThresholdMeters = 3,
    this.smoothingFactor = 0.3,
  });

  final double noiseThresholdMeters;
  final double smoothingFactor;

  double? _smoothedAltitude;
  double? _referenceAltitude;
  double _elevationGainMeters = 0;
  double _elevationLossMeters = 0;
  double? _highestElevationMeters;
  double? _lowestElevationMeters;

  double? get currentAltitudeMeters => _smoothedAltitude;

  double get elevationGainMeters => _elevationGainMeters;

  double get elevationLossMeters => _elevationLossMeters;

  double? get highestElevationMeters => _highestElevationMeters;

  double? get lowestElevationMeters => _lowestElevationMeters;

  void reset() {
    _smoothedAltitude = null;
    _referenceAltitude = null;
    _elevationGainMeters = 0;
    _elevationLossMeters = 0;
    _highestElevationMeters = null;
    _lowestElevationMeters = null;
  }

  /// Processes a raw GPS altitude sample (meters above sea level).
  void process(double? rawAltitudeMeters) {
    if (rawAltitudeMeters == null || !rawAltitudeMeters.isFinite) {
      return;
    }

    _smoothedAltitude = _smoothedAltitude == null
        ? rawAltitudeMeters
        : _smoothedAltitude! * (1 - smoothingFactor) +
            rawAltitudeMeters * smoothingFactor;

    final altitude = _smoothedAltitude!;

    if (_highestElevationMeters == null || altitude > _highestElevationMeters!) {
      _highestElevationMeters = altitude;
    }
    if (_lowestElevationMeters == null || altitude < _lowestElevationMeters!) {
      _lowestElevationMeters = altitude;
    }

    _referenceAltitude ??= altitude;

    final delta = altitude - _referenceAltitude!;
    if (delta >= noiseThresholdMeters) {
      _elevationGainMeters += delta;
      _referenceAltitude = altitude;
    } else if (delta <= -noiseThresholdMeters) {
      _elevationLossMeters += -delta;
      _referenceAltitude = altitude;
    }
  }
}
