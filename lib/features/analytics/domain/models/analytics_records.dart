import 'package:equatable/equatable.dart';

/// A single personal record card value.
class PersonalRecord extends Equatable {
  const PersonalRecord({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  List<Object?> get props => [label, value, subtitle];
}

/// Personal bests derived from persisted workouts.
class PersonalRecords extends Equatable {
  const PersonalRecords({
    required this.longestWorkout,
    required this.longestDistance,
    required this.fastestAverageSpeed,
    required this.highestCalories,
    required this.longestDuration,
  });

  final PersonalRecord longestWorkout;
  final PersonalRecord longestDistance;
  final PersonalRecord fastestAverageSpeed;
  final PersonalRecord highestCalories;
  final PersonalRecord longestDuration;

  @override
  List<Object?> get props => [
        longestWorkout,
        longestDistance,
        fastestAverageSpeed,
        highestCalories,
        longestDuration,
      ];
}

/// Streak metrics calculated from workout dates.
class StreakStats extends Equatable {
  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActiveDays,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalActiveDays,
      ];
}

/// Progress toward a weekly or monthly fitness goal.
class GoalProgressItem extends Equatable {
  const GoalProgressItem({
    required this.label,
    required this.progress,
    required this.valueLabel,
    required this.goalLabel,
  });

  final String label;
  final double progress;
  final String valueLabel;
  final String goalLabel;

  double get clampedProgress => progress.clamp(0.0, 1.0);

  int get progressPercent => (clampedProgress * 100).round();

  @override
  List<Object?> get props => [label, progress, valueLabel, goalLabel];
}
