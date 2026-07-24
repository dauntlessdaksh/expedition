/// Configurable thresholds for production-grade GPS filtering.
class LocationFilterConfig {
  const LocationFilterConfig({
    this.maxAccuracyMeters = 15,
    this.minMovementMeters = 5,
    this.minPolylineSegmentMeters = 5,
    this.movingSpeedThresholdMps = 0.8,
    this.minUpdateInterval = const Duration(seconds: 1),
    this.maxPlausibleSpeedMps = 12,
    this.speedSmoothingWindowSize = 5,
  });

  /// Reject fixes worse than this horizontal accuracy (meters).
  final double maxAccuracyMeters;

  /// Ignore updates that move less than this from the last accepted fix.
  final double minMovementMeters;

  /// Minimum spacing between polyline vertices (meters).
  final double minPolylineSegmentMeters;

  /// Speed above which elapsed time counts as moving time (m/s).
  final double movingSpeedThresholdMps;

  /// Minimum spacing between processed raw fixes.
  final Duration minUpdateInterval;

  /// Reject implied speeds above this between consecutive fixes (m/s).
  final double maxPlausibleSpeedMps;

  /// Number of recent speed samples used for smoothing.
  final int speedSmoothingWindowSize;
}
