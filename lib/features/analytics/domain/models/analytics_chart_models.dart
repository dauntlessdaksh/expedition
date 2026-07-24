import 'package:equatable/equatable.dart';

/// Distance covered on a single weekday for the weekly bar chart.
class AnalyticsWeeklyDay extends Equatable {
  const AnalyticsWeeklyDay({
    required this.label,
    required this.distanceKm,
  });

  final String label;
  final double distanceKm;

  @override
  List<Object?> get props => [label, distanceKm];
}

/// A single point on the monthly distance trend line chart.
class AnalyticsTrendPoint extends Equatable {
  const AnalyticsTrendPoint({
    required this.date,
    required this.distanceKm,
  });

  final DateTime date;
  final double distanceKm;

  @override
  List<Object?> get props => [date, distanceKm];
}

/// Percentage breakdown of workouts by activity category.
class ActivityDistribution extends Equatable {
  const ActivityDistribution({
    required this.walkingPercent,
    required this.runningPercent,
    required this.cyclingPercent,
    required this.otherPercent,
  });

  final double walkingPercent;
  final double runningPercent;
  final double cyclingPercent;
  final double otherPercent;

  bool get isEmpty =>
      walkingPercent == 0 &&
      runningPercent == 0 &&
      cyclingPercent == 0 &&
      otherPercent == 0;

  @override
  List<Object?> get props => [
        walkingPercent,
        runningPercent,
        cyclingPercent,
        otherPercent,
      ];
}
