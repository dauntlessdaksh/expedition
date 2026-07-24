/// Date-range filters for the workout history list.
enum HistoryFilter {
  today,
  last7Days,
  last30Days,
  allTime,
}

extension HistoryFilterLabel on HistoryFilter {
  String get label => switch (this) {
        HistoryFilter.today => 'Today',
        HistoryFilter.last7Days => 'Last 7 Days',
        HistoryFilter.last30Days => 'Last 30 Days',
        HistoryFilter.allTime => 'All Time',
      };
}
