/// Formats live activity metrics for display.
abstract final class ActivityFormatters {
  /// Workout elapsed time as `HH:MM:SS`.
  static String duration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String distanceKm(double meters) {
    final km = meters / 1000;
    if (km < 10) {
      return '${km.toStringAsFixed(2)} km';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  static String speedKmh(double metersPerSecond) {
    final kmh = metersPerSecond * 3.6;
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  static String gpsAccuracy(double meters) {
    return '±${meters.round()} m';
  }

  static String elevationMeters(double meters) {
    if (meters <= 0) return '0 m';
    return '${meters.round()} m';
  }
}
