import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/gamification_models.dart';
import '../../domain/models/goal.dart';

/// Drift persistence for achievements, goals, and challenges.
class GamificationLocalDataSource {
  const GamificationLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<Achievement>> getAchievements() async {
    final rows = await _database.select(_database.achievements).get();
    return rows.map(_mapAchievement).toList();
  }

  Future<Map<String, Achievement>> getAchievementMap() async {
    final achievements = await getAchievements();
    return {for (final item in achievements) item.id: item};
  }

  Future<void> upsertAchievement(Achievement achievement) {
    return _database.into(_database.achievements).insertOnConflictUpdate(
          AchievementsCompanion(
            id: Value(achievement.id),
            title: Value(achievement.title),
            description: Value(achievement.description),
            icon: Value(achievement.icon),
            progress: Value(achievement.progress),
            currentValue: Value(achievement.currentValue),
            targetValue: Value(achievement.targetValue),
            isUnlocked: Value(achievement.isUnlocked),
            unlockedDate: Value(achievement.unlockedDate),
          ),
        );
  }

  Future<void> upsertAchievements(List<Achievement> achievements) async {
    await _database.batch((batch) {
      for (final achievement in achievements) {
        batch.insert(
          _database.achievements,
          AchievementsCompanion(
            id: Value(achievement.id),
            title: Value(achievement.title),
            description: Value(achievement.description),
            icon: Value(achievement.icon),
            progress: Value(achievement.progress),
            currentValue: Value(achievement.currentValue),
            targetValue: Value(achievement.targetValue),
            isUnlocked: Value(achievement.isUnlocked),
            unlockedDate: Value(achievement.unlockedDate),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<Goal>> getGoals() async {
    final rows = await _database.select(_database.goals).get();
    return rows.map(_mapGoal).toList();
  }

  Future<void> upsertGoals(List<Goal> goals) async {
    await _database.batch((batch) {
      for (final goal in goals) {
        batch.insert(
          _database.goals,
          GoalsCompanion(
            id: Value(goal.id),
            title: Value(goal.title),
            targetValue: Value(goal.targetValue),
            currentValue: Value(goal.currentValue),
            period: Value(goal.period),
            periodStart: Value(goal.periodStart),
            updatedAt: Value(goal.updatedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<Challenge>> getChallenges() async {
    final rows = await (_database.select(_database.challenges)
          ..orderBy([
            (table) => OrderingTerm.desc(table.startDate),
          ]))
        .get();
    return rows.map(_mapChallenge).toList();
  }

  Future<void> upsertChallenges(List<Challenge> challenges) async {
    await _database.batch((batch) {
      for (final challenge in challenges) {
        batch.insert(
          _database.challenges,
          ChallengesCompanion(
            id: Value(challenge.id),
            title: Value(challenge.title),
            description: Value(challenge.description),
            type: Value(challenge.type),
            targetValue: Value(challenge.targetValue),
            currentValue: Value(challenge.currentValue),
            startDate: Value(challenge.startDate),
            endDate: Value(challenge.endDate),
            isCompleted: Value(challenge.isCompleted),
            completedAt: Value(challenge.completedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> deleteChallengesNotInWeek(DateTime weekStart) async {
    await (_database.delete(_database.challenges)
          ..where(
            (table) => table.startDate.isSmallerThanValue(weekStart),
          ))
        .go();
  }

  Achievement _mapAchievement(AchievementRow row) {
    return Achievement(
      id: row.id,
      title: row.title,
      description: row.description,
      icon: row.icon,
      progress: row.progress,
      currentValue: row.currentValue,
      targetValue: row.targetValue,
      isUnlocked: row.isUnlocked,
      unlockedDate: row.unlockedDate,
    );
  }

  Goal _mapGoal(GoalRow row) {
    return Goal(
      id: row.id,
      title: row.title,
      targetValue: row.targetValue,
      currentValue: row.currentValue,
      period: row.period,
      periodStart: row.periodStart,
      updatedAt: row.updatedAt,
    );
  }

  Challenge _mapChallenge(ChallengeRow row) {
    return Challenge(
      id: row.id,
      title: row.title,
      description: row.description,
      type: row.type,
      targetValue: row.targetValue,
      currentValue: row.currentValue,
      startDate: row.startDate,
      endDate: row.endDate,
      isCompleted: row.isCompleted,
      completedAt: row.completedAt,
    );
  }
}
