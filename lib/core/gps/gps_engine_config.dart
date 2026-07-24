/// Configurable thresholds for the outdoor GPS engine pipeline.
class GpsEngineConfig {
  const GpsEngineConfig({
    required this.gpsLockAccuracyMeters,
    required this.gpsLockSamplesRequired,
    required this.movementConfirmationMeters,
    required this.movementConfirmationSamples,
    required this.minimumConfirmationSpeedMps,
    required this.maximumConfirmationSpeedMps,
    required this.minimumMovementMeters,
    required this.minimumUpdateInterval,
    required this.speedSmoothingWindow,
    required this.stationarySamplesRequired,
    required this.minimumMovingSpeedMps,
    required this.maximumSpeedMps,
  });

  /// Maximum horizontal accuracy (meters) for GPS lock and movement samples.
  final double gpsLockAccuracyMeters;

  /// Consecutive accurate fixes required to acquire GPS lock.
  final int gpsLockSamplesRequired;

  /// Net displacement from movement origin required to confirm movement (meters).
  final double movementConfirmationMeters;

  /// Consecutive valid movement samples required to enter tracking.
  final int movementConfirmationSamples;

  /// Minimum speed to confirm outdoor movement (m/s) — ~1 km/h.
  final double minimumConfirmationSpeedMps;

  /// Maximum speed to confirm outdoor movement (m/s) — ~25 km/h.
  final double maximumConfirmationSpeedMps;

  /// Minimum segment length accepted while tracking (meters).
  final double minimumMovementMeters;

  /// Minimum spacing between processed raw fixes.
  final Duration minimumUpdateInterval;

  /// Rolling window size for speed smoothing while tracking.
  final int speedSmoothingWindow;

  /// Consecutive low-movement samples required to enter [GpsTrackingState.stopped].
  final int stationarySamplesRequired;

  /// Speed above which moving time accumulates while tracking (m/s).
  final double minimumMovingSpeedMps;

  /// Maximum plausible outdoor speed for the activity profile (m/s).
  final double maximumSpeedMps;

  /// Outdoor running — primary Expedition profile.
  factory GpsEngineConfig.running() {
    return const GpsEngineConfig(
      gpsLockAccuracyMeters: 12,
      gpsLockSamplesRequired: 3,
      movementConfirmationMeters: 10,
      movementConfirmationSamples: 4,
      minimumConfirmationSpeedMps: 1 / 3.6,
      maximumConfirmationSpeedMps: 25 / 3.6,
      minimumMovementMeters: 5,
      minimumUpdateInterval: Duration(seconds: 1),
      speedSmoothingWindow: 5,
      stationarySamplesRequired: 4,
      minimumMovingSpeedMps: 1 / 3.6,
      maximumSpeedMps: 25 / 3.6,
    );
  }

  /// Alias kept for callers that reference the walking profile.
  factory GpsEngineConfig.walking() => GpsEngineConfig.running();

  /// Alias kept for callers that reference the cycling profile.
  factory GpsEngineConfig.cycling() {
    return GpsEngineConfig(
      gpsLockAccuracyMeters: 12,
      gpsLockSamplesRequired: 3,
      movementConfirmationMeters: 10,
      movementConfirmationSamples: 4,
      minimumConfirmationSpeedMps: 1 / 3.6,
      maximumConfirmationSpeedMps: 60 / 3.6,
      minimumMovementMeters: 5,
      minimumUpdateInterval: const Duration(seconds: 1),
      speedSmoothingWindow: 5,
      stationarySamplesRequired: 4,
      minimumMovingSpeedMps: 1 / 3.6,
      maximumSpeedMps: 60 / 3.6,
    );
  }
}
