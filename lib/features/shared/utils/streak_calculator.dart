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

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
