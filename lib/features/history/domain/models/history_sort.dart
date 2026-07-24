/// Sort options for the workout history list.
enum HistorySort {
  newestFirst,
  oldestFirst,
  longestDistance,
  longestDuration,
  highestCalories,
}

extension HistorySortLabel on HistorySort {
  String get label => switch (this) {
        HistorySort.newestFirst => 'Newest First',
        HistorySort.oldestFirst => 'Oldest First',
        HistorySort.longestDistance => 'Longest Distance',
        HistorySort.longestDuration => 'Longest Duration',
        HistorySort.highestCalories => 'Highest Calories',
      };
}
