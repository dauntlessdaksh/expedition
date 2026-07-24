import '../models/gamification_models.dart';

/// Catalog of all achievements tracked by Expedition.
abstract final class AchievementCatalog {
  static const definitions = <AchievementDefinition>[
    AchievementDefinition(
      id: 'first_workout',
      title: 'First Workout',
      description: 'Complete your first workout',
      icon: '🏅',
      targetValue: 1,
      valueExtractor: _totalWorkouts,
    ),
    AchievementDefinition(
      id: 'walk_10km',
      title: 'Walk 10 km',
      description: 'Cover 10 km total distance',
      icon: '🏅',
      targetValue: 10,
      valueExtractor: _totalDistanceKm,
    ),
    AchievementDefinition(
      id: 'walk_50km',
      title: 'Walk 50 km',
      description: 'Cover 50 km total distance',
      icon: '🏅',
      targetValue: 50,
      valueExtractor: _totalDistanceKm,
    ),
    AchievementDefinition(
      id: 'walk_100km',
      title: 'Walk 100 km',
      description: 'Cover 100 km total distance',
      icon: '🏅',
      targetValue: 100,
      valueExtractor: _totalDistanceKm,
    ),
    AchievementDefinition(
      id: 'streak_7',
      title: '7 Day Streak',
      description: 'Stay active for 7 consecutive days',
      icon: '🏅',
      targetValue: 7,
      valueExtractor: _longestStreak,
    ),
    AchievementDefinition(
      id: 'streak_30',
      title: '30 Day Streak',
      description: 'Stay active for 30 consecutive days',
      icon: '🏅',
      targetValue: 30,
      valueExtractor: _longestStreak,
    ),
    AchievementDefinition(
      id: 'burn_5000_calories',
      title: 'Burn 5000 Calories',
      description: 'Burn 5,000 calories across all workouts',
      icon: '🏅',
      targetValue: 5000,
      valueExtractor: _totalCalories,
    ),
    AchievementDefinition(
      id: 'complete_50_activities',
      title: 'Complete 50 Activities',
      description: 'Finish 50 tracked workouts',
      icon: '🏅',
      targetValue: 50,
      valueExtractor: _totalWorkouts,
    ),
  ];

  static double _totalWorkouts(GamificationMetrics metrics) =>
      metrics.totalWorkouts.toDouble();

  static double _totalDistanceKm(GamificationMetrics metrics) =>
      metrics.totalDistanceKm;

  static double _longestStreak(GamificationMetrics metrics) =>
      metrics.longestStreak.toDouble();

  static double _totalCalories(GamificationMetrics metrics) =>
      metrics.totalCalories.toDouble();
}

/// Distance milestones displayed on the gamification timeline.
abstract final class MilestoneCatalog {
  static const distancesKm = [25.0, 50.0, 100.0, 250.0, 500.0, 1000.0];
}

/// Goal identifiers persisted in Drift.
abstract final class GoalIds {
  static const dailySteps = 'daily_steps';
  static const weeklyDistance = 'weekly_distance';
  static const monthlyWorkouts = 'monthly_workouts';
  static const dailyActiveMinutes = 'daily_active_minutes';
}

/// Challenge type identifiers.
abstract final class ChallengeTypes {
  static const weeklyDistance = 'weekly_distance';
  static const weeklyWorkouts = 'weekly_workouts';
  static const consecutiveDays = 'consecutive_days';
}
