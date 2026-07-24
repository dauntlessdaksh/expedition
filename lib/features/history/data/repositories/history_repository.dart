import '../../domain/models/workout.dart';
import 'workout_repository.dart';

/// History-facing repository that delegates to [WorkoutRepository].
class HistoryRepository {
  const HistoryRepository(this._workoutRepository);

  final WorkoutRepository _workoutRepository;

  Future<List<Workout>> getAllWorkouts() {
    return _workoutRepository.getAllWorkouts();
  }

  Future<Workout?> getWorkoutById(int id) {
    return _workoutRepository.getWorkoutById(id);
  }

  Future<void> deleteWorkout(int id) {
    return _workoutRepository.deleteWorkout(id);
  }
}
