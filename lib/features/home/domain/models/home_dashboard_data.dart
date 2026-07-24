import 'package:equatable/equatable.dart';

/// A single day's activity value for the weekly chart.
class WeeklyActivityDay extends Equatable {
  const WeeklyActivityDay({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}

/// Daily fitness metrics displayed on the home dashboard.
class DailyStats extends Equatable {
  const DailyStats({
    required this.steps,
    required this.stepsGoal,
    required this.calories,
    required this.caloriesGoal,
    required this.distanceKm,
    required this.distanceGoalKm,
    required this.activeMinutes,
    required this.activeMinutesGoal,
  });

  final int steps;
  final int stepsGoal;
  final int calories;
  final int caloriesGoal;
  final double distanceKm;
  final double distanceGoalKm;
  final int activeMinutes;
  final int activeMinutesGoal;

  double get stepsProgress => steps / stepsGoal;
  double get caloriesProgress => calories / caloriesGoal;
  double get distanceProgress => distanceKm / distanceGoalKm;
  double get activeMinutesProgress => activeMinutes / activeMinutesGoal;

  /// Primary ring progress driven by step count.
  double get primaryProgress => stepsProgress.clamp(0.0, 1.0);

  int get primaryProgressPercent => (primaryProgress * 100).round();

  @override
  List<Object?> get props => [
        steps,
        stepsGoal,
        calories,
        caloriesGoal,
        distanceKm,
        distanceGoalKm,
        activeMinutes,
        activeMinutesGoal,
      ];
}

/// Aggregated home dashboard content.
class HomeDashboardData extends Equatable {
  const HomeDashboardData({
    required this.userName,
    required this.gender,
    required this.stats,
    required this.streakDays,
    required this.weeklyActivity,
  });

  final String userName;
  final String gender;
  final DailyStats stats;
  final int streakDays;
  final List<WeeklyActivityDay> weeklyActivity;

  @override
  List<Object?> get props => [
        userName,
        gender,
        stats,
        streakDays,
        weeklyActivity,
      ];
}
