import '../../domain/models/history_filter.dart';
import '../../domain/models/history_sort.dart';
import '../../domain/models/workout.dart';
import '../../../shared/utils/workout_display_formatters.dart';

/// Applies search, filter, and sort rules to workout history lists.
abstract final class HistoryQueryEngine {
  static List<Workout> apply({
    required List<Workout> workouts,
    required String searchQuery,
    required HistoryFilter filter,
    required HistorySort sort,
    DateTime? referenceDate,
  }) {
    final filtered = workouts.where((workout) {
      return _matchesFilter(workout, filter, referenceDate ?? DateTime.now()) &&
          _matchesSearch(workout, searchQuery);
    }).toList();

    filtered.sort((a, b) => _compare(a, b, sort));
    return filtered;
  }

  static bool _matchesSearch(Workout workout, String searchQuery) {
    if (searchQuery.trim().isEmpty) {
      return true;
    }

    final query = searchQuery.trim().toLowerCase();
    final label =
        WorkoutDisplayFormatters.activityType(workout.activityType).toLowerCase();

    return label.contains(query) || workout.activityType.toLowerCase().contains(query);
  }

  static bool _matchesFilter(
    Workout workout,
    HistoryFilter filter,
    DateTime referenceDate,
  ) {
    final start = _startOfDay(referenceDate);

    return switch (filter) {
      HistoryFilter.today => !_isBeforeDay(workout.startTime, start),
      HistoryFilter.last7Days => !workout.startTime
          .isBefore(start.subtract(const Duration(days: 6))),
      HistoryFilter.last30Days => !workout.startTime
          .isBefore(start.subtract(const Duration(days: 29))),
      HistoryFilter.allTime => true,
    };
  }

  static int _compare(Workout a, Workout b, HistorySort sort) {
    return switch (sort) {
      HistorySort.newestFirst => b.startTime.compareTo(a.startTime),
      HistorySort.oldestFirst => a.startTime.compareTo(b.startTime),
      HistorySort.longestDistance =>
        b.distanceInMeters.compareTo(a.distanceInMeters),
      HistorySort.longestDuration =>
        b.durationInSeconds.compareTo(a.durationInSeconds),
      HistorySort.highestCalories => b.calories.compareTo(a.calories),
    };
  }

  static DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool _isBeforeDay(DateTime value, DateTime dayStart) {
    return _startOfDay(value).isBefore(dayStart);
  }
}
