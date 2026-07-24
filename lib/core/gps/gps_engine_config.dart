/// Configurable thresholds for the GPS engine pipeline.
class GpsEngineConfig {
  const GpsEngineConfig({
    required this.minimumAccuracy,
    required this.minimumMovementMeters,
    required this.minimumUpdateInterval,
    required this.speedSmoothingWindow,
    required this.stationarySamplesRequired,
    required this.minimumMovingSpeedMps,
    required this.maximumSpeedMps,
  });

  /// Reject fixes with horizontal accuracy worse than this value (meters).
  final double minimumAccuracy;

  /// Ignore movement smaller than this distance (meters).
  final double minimumMovementMeters;

  /// Minimum spacing between processed raw fixes.
  final Duration minimumUpdateInterval;

  /// Rolling window size for speed smoothing.
  final int speedSmoothingWindow;

  /// Consecutive low-movement samples required to enter stationary state.
  final int stationarySamplesRequired;

  /// Speed above which moving time accumulates (m/s).
  final double minimumMovingSpeedMps;

  /// Maximum plausible speed for the activity profile (m/s).
  final double maximumSpeedMps;

  /// Walking profile — up to ~8 km/h.
  factory GpsEngineConfig.walking() {
    return const GpsEngineConfig(
      minimumAccuracy: 15,
      minimumMovementMeters: 5,
      minimumUpdateInterval: Duration(seconds: 1),
      speedSmoothingWindow: 5,
      stationarySamplesRequired: 3,
      minimumMovingSpeedMps: 0.8,
      maximumSpeedMps: 8 / 3.6,
    );
  }

  /// Running profile — up to ~25 km/h.
  factory GpsEngineConfig.running() {
    return const GpsEngineConfig(
      minimumAccuracy: 15,
      minimumMovementMeters: 5,
      minimumUpdateInterval: Duration(seconds: 1),
      speedSmoothingWindow: 5,
      stationarySamplesRequired: 3,
      minimumMovingSpeedMps: 0.8,
      maximumSpeedMps: 25 / 3.6,
    );
  }

  /// Cycling profile — up to ~60 km/h.
  factory GpsEngineConfig.cycling() {
    return const GpsEngineConfig(
      minimumAccuracy: 15,
      minimumMovementMeters: 5,
      minimumUpdateInterval: Duration(seconds: 1),
      speedSmoothingWindow: 5,
      stationarySamplesRequired: 3,
      minimumMovingSpeedMps: 0.8,
      maximumSpeedMps: 60 / 3.6,
    );
  }
}
