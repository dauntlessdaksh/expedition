import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/achievements_table.dart';
import 'tables/challenges_table.dart';
import 'tables/goals_table.dart';
import 'tables/settings_table.dart';
import 'tables/users_table.dart';
import 'tables/workouts_table.dart';

part 'app_database.g.dart';

/// Local SQLite database for offline-first data persistence.
@DriftDatabase(
  tables: [Users, Settings, Workouts, Achievements, Goals, Challenges],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(users);
          await m.createTable(settings);
        }
        if (from < 3) {
          await m.deleteTable('users');
          await m.createTable(users);
        }
        if (from < 4) {
          await m.createTable(workouts);
        }
        if (from < 5) {
          await m.addColumn(settings, settings.weeklyDistanceGoal);
          await m.addColumn(settings, settings.weeklyWorkoutGoal);
        }
        if (from < 6) {
          await m.createTable(achievements);
          await m.createTable(goals);
          await m.createTable(challenges);
          await m.addColumn(settings, settings.dailyActiveMinutesGoal);
          await m.addColumn(settings, settings.monthlyWorkoutGoal);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'expedition');
  }
}
