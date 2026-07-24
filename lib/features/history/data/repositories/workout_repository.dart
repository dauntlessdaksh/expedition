import '../../domain/models/workout.dart';
import '../datasource/workout_local_datasource.dart';

/// Repository for persisted workout sessions.
class WorkoutRepository {
  const WorkoutRepository(this._localDataSource);

  final WorkoutLocalDataSource _localDataSource;

  Future<Workout> saveWorkout(Workout workout) async {
    final id = await _localDataSource.insertWorkout(workout);
    return workout.copyWith(id: id);
  }

  Future<List<Workout>> getAllWorkouts() {
    return _localDataSource.getAllWorkouts();
  }

  Future<Workout?> getWorkoutById(int id) {
    return _localDataSource.getWorkoutById(id);
  }

  Future<List<Workout>> getTodaysWorkouts([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _localDataSource.getWorkoutsBetween(
      startInclusive: start,
      endExclusive: end,
    );
  }

  Future<List<Workout>> getWeeklyWorkouts([DateTime? referenceDate]) {
    final now = referenceDate ?? DateTime.now();
    final start = _startOfWeek(now);
    final end = start.add(const Duration(days: 7));
    return _localDataSource.getWorkoutsBetween(
      startInclusive: start,
      endExclusive: end,
    );
  }

  Future<void> deleteWorkout(int id) {
    return _localDataSource.deleteWorkout(id);
  }

  Future<void> clearAll() {
    return _localDataSource.clearAll();
  }

  DateTime _startOfWeek(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    return dayStart.subtract(Duration(days: dayStart.weekday - DateTime.monday));
  }
}
