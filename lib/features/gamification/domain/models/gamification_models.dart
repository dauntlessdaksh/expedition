import 'package:equatable/equatable.dart';

import 'goal.dart';
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
    required this.isUnlocked,
    this.unlockedDate,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final double progress;
  final double currentValue;
  final double targetValue;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  double get clampedProgress => progress.clamp(0.0, 1.0);

  int get progressPercent => (clampedProgress * 100).round();

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        progress,
        currentValue,
        targetValue,
        isUnlocked,
        unlockedDate,
      ];
}

/// Static achievement template used to seed and evaluate progress.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.valueExtractor,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final double targetValue;
  final double Function(GamificationMetrics metrics) valueExtractor;
}

/// Aggregated workout metrics used by the gamification engine.
class GamificationMetrics extends Equatable {
  const GamificationMetrics({
    required this.totalWorkouts,
    required this.totalDistanceKm,
    required this.totalCalories,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyDistanceKm,
    required this.weeklyWorkouts,
    required this.weeklyActiveDays,
    required this.monthlyWorkouts,
    required this.todaySteps,
    required this.todayActiveMinutes,
    required this.todayDistanceKm,
  });

  final int totalWorkouts;
  final double totalDistanceKm;
  final int totalCalories;
  final int currentStreak;
  final int longestStreak;
  final double weeklyDistanceKm;
  final int weeklyWorkouts;
  final int weeklyActiveDays;
  final int monthlyWorkouts;
  final int todaySteps;
  final int todayActiveMinutes;
  final double todayDistanceKm;

  @override
  List<Object?> get props => [
        totalWorkouts,
        totalDistanceKm,
        totalCalories,
        currentStreak,
        longestStreak,
        weeklyDistanceKm,
        weeklyWorkouts,
        weeklyActiveDays,
        monthlyWorkouts,
        todaySteps,
        todayActiveMinutes,
        todayDistanceKm,
      ];
}

/// Result returned after syncing gamification state post-workout.
class GamificationSyncResult extends Equatable {
  const GamificationSyncResult({
    required this.newlyUnlocked,
    required this.achievements,
    required this.goals,
    required this.challenges,
    required this.stats,
  });

  final List<Achievement> newlyUnlocked;
  final List<Achievement> achievements;
  final List<Goal> goals;
  final List<Challenge> challenges;
  final GamificationStats stats;

  @override
  List<Object?> get props => [
        newlyUnlocked,
        achievements,
        goals,
        challenges,
        stats,
      ];
}

/// High-level gamification summary statistics.
class GamificationStats extends Equatable {
  const GamificationStats({
    required this.unlockedCount,
    required this.totalAchievements,
    required this.currentLevel,
    required this.nextGoalTitle,
    required this.completionPercent,
    required this.totalDistanceKm,
  });

  final int unlockedCount;
  final int totalAchievements;
  final int currentLevel;
  final String nextGoalTitle;
  final int completionPercent;
  final double totalDistanceKm;

  @override
  List<Object?> get props => [
        unlockedCount,
        totalAchievements,
        currentLevel,
        nextGoalTitle,
        completionPercent,
        totalDistanceKm,
      ];
}

/// Distance milestone marker for the timeline UI.
class Milestone extends Equatable {
  const Milestone({
    required this.distanceKm,
    required this.isReached,
    required this.progress,
  });

  final double distanceKm;
  final bool isReached;
  final double progress;

  @override
  List<Object?> get props => [distanceKm, isReached, progress];
}
