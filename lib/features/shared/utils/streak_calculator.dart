/// Calculates consecutive-day activity streaks from workout dates.
abstract final class StreakCalculator {
  static int calculate(Iterable<DateTime> workoutDates) {
    if (workoutDates.isEmpty) {
      return 0;
    }

    final uniqueDays = workoutDates.map(_dateOnly).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (uniqueDays.first != today && uniqueDays.first != yesterday) {
      return 0;
    }

    var streak = 1;
    for (var index = 0; index < uniqueDays.length - 1; index++) {
      final difference = uniqueDays[index].difference(uniqueDays[index + 1]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Returns the longest consecutive-day streak in the workout history.
  static int longestStreak(Iterable<DateTime> workoutDates) {
    if (workoutDates.isEmpty) {
      return 0;
    }

    final uniqueDays = workoutDates.map(_dateOnly).toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    var longest = 1;
    var current = 1;

    for (var index = 1; index < uniqueDays.length; index++) {
      final difference =
          uniqueDays[index].difference(uniqueDays[index - 1]).inDays;
      if (difference == 1) {
        current++;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 1;
      }
    }

    return longest;
  }

  /// Returns the number of unique days with at least one workout.
  static int totalActiveDays(Iterable<DateTime> workoutDates) {
    return workoutDates.map(_dateOnly).toSet().length;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
