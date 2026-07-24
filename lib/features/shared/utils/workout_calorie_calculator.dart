/// Estimates calories burned for GPS-tracked workouts.
abstract final class WorkoutCalorieCalculator {
  /// Uses MET-based estimation for outdoor running/walking.
  static int estimate({
    required int durationSeconds,
    required double distanceMeters,
    required double weightKg,
  }) {
    if (durationSeconds <= 0) {
      return 0;
    }

    final hours = durationSeconds / 3600;
    final distanceKm = distanceMeters / 1000;
    final met = distanceKm >= 3 ? 9.8 : 6.0;

    return (met * weightKg * hours).round().clamp(0, 100000);
  }
}
