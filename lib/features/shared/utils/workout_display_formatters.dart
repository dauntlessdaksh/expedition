import 'package:intl/intl.dart';

import '../../activity/presentation/utils/activity_formatters.dart';

/// Shared display formatting for persisted workouts.
abstract final class WorkoutDisplayFormatters {
  static String activityType(String rawType) {
    return rawType
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  static String durationSeconds(int seconds) {
    return ActivityFormatters.duration(Duration(seconds: seconds));
  }

  static String distanceMeters(double meters) {
    return ActivityFormatters.distanceKm(meters);
  }

  static String speedMps(double metersPerSecond) {
    return ActivityFormatters.speedKmh(metersPerSecond);
  }

  static String workoutDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d · h:mm a').format(dateTime);
  }

  static String workoutDateShort(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  static String timeOfDay(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String elevationMeters(double meters) {
    if (meters <= 0) return '0 m';
    return '${meters.round()} m';
  }

  static String elevationDeltaMeters(double meters) {
    if (meters <= 0) return '0 m';
    return '+${meters.round()} m';
  }

  static String elevationChangeMeters(double meters) {
    if (meters <= 0) return '0 m';
    return '${meters.round()} m';
  }
}
