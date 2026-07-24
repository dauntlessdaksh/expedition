/// Formats live activity metrics for display.
abstract final class ActivityFormatters {
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
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
}
