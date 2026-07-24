/// MET-based active calorie estimation for GPS-tracked workouts.
///
/// Calories only accumulate during confirmed movement segments.
class CalorieCalculator {
  double _activeCalories = 0;
  String _activityType = 'run';
  double _weightKg = 70;

  double get activeCalories => _activeCalories;

  int get activeCaloriesRounded => _activeCalories.round().clamp(0, 100000);

  void configure({
    required String activityType,
    required double weightKg,
  }) {
    _activityType = activityType.toLowerCase();
    _weightKg = weightKg > 0 ? weightKg : 70;
  }

  void reset() {
    _activeCalories = 0;
  }

  /// Increments active calories for an accepted moving GPS segment.
  void applyMovingSegment({
    required double deltaSeconds,
    required double currentSpeedMps,
    required bool isMoving,
    required bool gpsMovementAccepted,
  }) {
    if (!isMoving ||
        currentSpeedMps <= 0 ||
        !gpsMovementAccepted ||
        deltaSeconds <= 0) {
      return;
    }

    final met = _metForActivity(_activityType, currentSpeedMps);
    final movingMinutes = deltaSeconds / 60;
    final increment = (met * 3.5 * _weightKg / 200) * movingMinutes;
    _activeCalories += increment;
  }

  /// Returns MET for [activityType] at [speedMps].
  static double metForActivity(String activityType, double speedMps) {
    return _metForActivity(activityType.toLowerCase(), speedMps);
  }

  static double _metForActivity(String activityType, double speedMps) {
    final speedKmh = speedMps * 3.6;

    if (activityType.contains('walk')) {
      if (speedKmh < 4) return 3.5;
      if (speedKmh < 5.5) return 4.0;
      return 4.5;
    }

    if (activityType.contains('run')) {
      if (speedKmh < 8) return 7.0;
      if (speedKmh < 11) return 9.5;
      return 11.0;
    }

    if (activityType.contains('hike')) {
      if (speedKmh < 3) return 6.0;
      if (speedKmh < 5) return 7.0;
      return 8.0;
    }

    if (activityType.contains('cycle') || activityType.contains('bike')) {
      if (speedKmh < 15) return 6.0;
      if (speedKmh < 22) return 8.0;
      return 10.0;
    }

    // Default outdoor cardio profile.
    if (speedKmh < 6) return 4.0;
    if (speedKmh < 10) return 8.0;
    return 10.0;
  }
}
