import '../../../history/domain/models/workout.dart';
import '../../../profile/domain/models/profile_models.dart';
import '../../../shared/utils/streak_calculator.dart';
import '../../domain/models/gamification_models.dart';
import '../../domain/models/goal.dart';
import '../../domain/services/achievement_catalog.dart';
import '../../data/datasource/gamification_local_datasource.dart';

/// Computes and persists gamification progress from workout history.
class GamificationEngine {
  const GamificationEngine(this._localDataSource);

  final GamificationLocalDataSource _localDataSource;

  static const _stepsPerKm = 1300;

  Future<GamificationSyncResult> sync({
    required List<Workout> workouts,
    required UserPreferences preferences,
  }) async {
    final metrics = _buildMetrics(workouts);
    final existingMap = await _localDataSource.getAchievementMap();
    final now = DateTime.now();

    final updatedAchievements = <Achievement>[];
    final newlyUnlocked = <Achievement>[];

    for (final definition in AchievementCatalog.definitions) {
      final currentValue = definition.valueExtractor(metrics);
      final progress = definition.targetValue <= 0
          ? 0.0
          : (currentValue / definition.targetValue).clamp(0.0, 1.0);
      final isUnlocked = currentValue >= definition.targetValue;
      final previous = existingMap[definition.id];
      final wasUnlocked = previous?.isUnlocked ?? false;

      DateTime? unlockedDate = previous?.unlockedDate;
      if (isUnlocked && !wasUnlocked) {
        unlockedDate = now;
      } else if (!isUnlocked) {
        unlockedDate = null;
      }

      final achievement = Achievement(
        id: definition.id,
        title: definition.title,
        description: definition.description,
        icon: definition.icon,
        progress: progress,
        currentValue: currentValue,
        targetValue: definition.targetValue,
        isUnlocked: isUnlocked,
        unlockedDate: unlockedDate,
      );

      updatedAchievements.add(achievement);
      if (isUnlocked && !wasUnlocked) {
        newlyUnlocked.add(achievement);
      }
    }

    await _localDataSource.upsertAchievements(updatedAchievements);

    final goals = _buildGoals(metrics, preferences, now);
    await _localDataSource.upsertGoals(goals);

    final weekStart = _startOfWeek(now);
    await _localDataSource.deleteChallengesNotInWeek(weekStart);
    final existingChallenges = await _localDataSource.getChallenges();
    final challenges = _buildChallenges(
      metrics: metrics,
      weekStart: weekStart,
      weekEnd: weekStart.add(const Duration(days: 7)),
      existing: existingChallenges,
      now: now,
    );
    await _localDataSource.upsertChallenges(challenges);

    final stats = _buildStats(updatedAchievements, metrics);

    return GamificationSyncResult(
      newlyUnlocked: newlyUnlocked,
      achievements: updatedAchievements,
      goals: goals,
      challenges: challenges,
      stats: stats,
    );
  }

  List<Milestone> buildMilestones(double totalDistanceKm) {
    return MilestoneCatalog.distancesKm.map((distanceKm) {
      final progress = (totalDistanceKm / distanceKm).clamp(0.0, 1.0);
      return Milestone(
        distanceKm: distanceKm,
        isReached: totalDistanceKm >= distanceKm,
        progress: progress,
      );
    }).toList();
  }

  GamificationMetrics _buildMetrics(List<Workout> workouts) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final weekStart = _startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);

    final todayWorkouts = workouts.where(
      (workout) =>
          !workout.startTime.isBefore(todayStart) &&
          workout.startTime.isBefore(todayEnd),
    );
    final weeklyWorkouts = workouts.where(
      (workout) =>
          !workout.startTime.isBefore(weekStart) &&
          workout.startTime.isBefore(weekEnd),
    );
    final monthlyWorkouts = workouts.where(
      (workout) =>
          !workout.startTime.isBefore(monthStart) &&
          workout.startTime.isBefore(monthEnd),
    );

    final totalDistanceKm = workouts.fold<double>(
          0,
          (total, workout) => total + workout.distanceInMeters,
        ) /
        1000;
    final weeklyDistanceKm = weeklyWorkouts.fold<double>(
          0,
          (total, workout) => total + workout.distanceInMeters,
        ) /
        1000;
    final todayDistanceKm = todayWorkouts.fold<double>(
          0,
          (total, workout) => total + workout.distanceInMeters,
        ) /
        1000;
    final todayActiveMinutes = todayWorkouts.fold<int>(
      0,
      (total, workout) => total + (workout.durationInSeconds ~/ 60),
    );

    final workoutDates = workouts.map((workout) => workout.startTime);
    final weeklyDates = weeklyWorkouts.map((workout) => workout.startTime).toSet();

    return GamificationMetrics(
      totalWorkouts: workouts.length,
      totalDistanceKm: totalDistanceKm,
      totalCalories: workouts.fold<int>(
        0,
        (total, workout) => total + workout.calories,
      ),
      currentStreak: StreakCalculator.calculate(workoutDates),
      longestStreak: StreakCalculator.longestStreak(workoutDates),
      weeklyDistanceKm: weeklyDistanceKm,
      weeklyWorkouts: weeklyWorkouts.length,
      weeklyActiveDays: weeklyDates.length,
      monthlyWorkouts: monthlyWorkouts.length,
      todaySteps: (todayDistanceKm * _stepsPerKm).round(),
      todayActiveMinutes: todayActiveMinutes,
      todayDistanceKm: todayDistanceKm,
    );
  }

  List<Goal> _buildGoals(
    GamificationMetrics metrics,
    UserPreferences preferences,
    DateTime now,
  ) {
    final dayStart = DateTime(now.year, now.month, now.day);
    final weekStart = _startOfWeek(now);
    final monthStart = DateTime(now.year, now.month);

    return [
      Goal(
        id: GoalIds.dailySteps,
        title: 'Daily Step Goal',
        targetValue: preferences.dailyStepGoal.toDouble(),
        currentValue: metrics.todaySteps.toDouble(),
        period: 'daily',
        periodStart: dayStart,
        updatedAt: now,
      ),
      Goal(
        id: GoalIds.weeklyDistance,
        title: 'Weekly Distance Goal',
        targetValue: preferences.weeklyDistanceGoalKm,
        currentValue: metrics.weeklyDistanceKm,
        period: 'weekly',
        periodStart: weekStart,
        updatedAt: now,
      ),
      Goal(
        id: GoalIds.monthlyWorkouts,
        title: 'Monthly Workout Goal',
        targetValue: preferences.monthlyWorkoutGoal.toDouble(),
        currentValue: metrics.monthlyWorkouts.toDouble(),
        period: 'monthly',
        periodStart: monthStart,
        updatedAt: now,
      ),
      Goal(
        id: GoalIds.dailyActiveMinutes,
        title: 'Daily Active Minutes',
        targetValue: preferences.dailyActiveMinutesGoal.toDouble(),
        currentValue: metrics.todayActiveMinutes.toDouble(),
        period: 'daily',
        periodStart: dayStart,
        updatedAt: now,
      ),
    ];
  }

  List<Challenge> _buildChallenges({
    required GamificationMetrics metrics,
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<Challenge> existing,
    required DateTime now,
  }) {
    final existingMap = {
      for (final challenge in existing) challenge.id: challenge,
    };

    final templates = [
      (
        id: '${ChallengeTypes.weeklyDistance}_${weekStart.millisecondsSinceEpoch}',
        title: 'Walk 20 km this week',
        description: 'Cover 20 kilometers before the week ends',
        type: ChallengeTypes.weeklyDistance,
        targetValue: 20.0,
        currentValue: metrics.weeklyDistanceKm,
      ),
      (
        id: '${ChallengeTypes.weeklyWorkouts}_${weekStart.millisecondsSinceEpoch}',
        title: 'Complete 5 workouts',
        description: 'Finish five workouts this week',
        type: ChallengeTypes.weeklyWorkouts,
        targetValue: 5.0,
        currentValue: metrics.weeklyWorkouts.toDouble(),
      ),
      (
        id: '${ChallengeTypes.consecutiveDays}_${weekStart.millisecondsSinceEpoch}',
        title: 'Be active 7 consecutive days',
        description: 'Maintain a seven-day activity streak',
        type: ChallengeTypes.consecutiveDays,
        targetValue: 7.0,
        currentValue: metrics.currentStreak.toDouble(),
      ),
    ];

    return templates.map((template) {
      final previous = existingMap[template.id];
      final isCompleted = template.currentValue >= template.targetValue;
      final completedAt = isCompleted
          ? (previous?.completedAt ?? now)
          : null;

      return Challenge(
        id: template.id,
        title: template.title,
        description: template.description,
        type: template.type,
        targetValue: template.targetValue,
        currentValue: template.currentValue,
        startDate: weekStart,
        endDate: weekEnd,
        isCompleted: isCompleted,
        completedAt: completedAt,
      );
    }).toList();
  }

  GamificationStats _buildStats(
    List<Achievement> achievements,
    GamificationMetrics metrics,
  ) {
    final unlocked = achievements.where((item) => item.isUnlocked).length;
    final total = achievements.length;
    final completionPercent =
        total == 0 ? 0 : ((unlocked / total) * 100).round();

    final nextLocked = achievements
        .where((item) => !item.isUnlocked)
        .toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));

    final nextGoalTitle =
        nextLocked.isEmpty ? 'All achievements unlocked' : nextLocked.first.title;

    final level = 1 +
        (unlocked ~/ 2) +
        (metrics.totalDistanceKm ~/ 50).floor();

    return GamificationStats(
      unlockedCount: unlocked,
      totalAchievements: total,
      currentLevel: level.clamp(1, 99),
      nextGoalTitle: nextGoalTitle,
      completionPercent: completionPercent,
      totalDistanceKm: metrics.totalDistanceKm,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    return dayStart.subtract(Duration(days: dayStart.weekday - DateTime.monday));
  }
}
