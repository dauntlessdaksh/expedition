import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/workout.dart';

/// Drift-backed persistence for workout sessions.
class WorkoutLocalDataSource {
  const WorkoutLocalDataSource(this._database);

  final AppDatabase _database;

  Future<int> insertWorkout(Workout workout) {
    return _database.into(_database.workouts).insert(workout.toCompanion());
  }

  Future<List<Workout>> getAllWorkouts() async {
    final rows = await (_database.select(_database.workouts)
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.startTime,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();

    return rows.map(Workout.fromRow).toList();
  }

  Future<Workout?> getWorkoutById(int id) async {
    final row = await (_database.select(_database.workouts)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();

    return row == null ? null : Workout.fromRow(row);
  }

  Future<List<Workout>> getWorkoutsBetween({
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    final rows = await (_database.select(_database.workouts)
          ..where(
            (table) => table.startTime.isBiggerOrEqualValue(startInclusive) &
                table.startTime.isSmallerThanValue(endExclusive),
          )
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.startTime,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();

    return rows.map(Workout.fromRow).toList();
  }

  Future<int> deleteWorkout(int id) {
    return (_database.delete(_database.workouts)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> clearAll() async {
    await _database.delete(_database.workouts).go();
  }
}
