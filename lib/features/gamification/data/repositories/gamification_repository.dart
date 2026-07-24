import '../../../history/data/repositories/workout_repository.dart';
import '../../../profile/data/datasource/profile_local_datasource.dart';
import '../../domain/models/gamification_models.dart';
import '../../domain/models/goal.dart';
import '../../domain/services/gamification_engine.dart';
import '../datasource/gamification_local_datasource.dart';

/// Coordinates gamification sync after workouts and read APIs for blocs.
class GamificationRepository {
  GamificationRepository({
    required GamificationLocalDataSource localDataSource,
    required WorkoutRepository workoutRepository,
    required ProfileLocalDataSource profileLocalDataSource,
  })  : _localDataSource = localDataSource,
        _workoutRepository = workoutRepository,
        _profileLocalDataSource = profileLocalDataSource,
        _engine = GamificationEngine(localDataSource);

  final GamificationLocalDataSource _localDataSource;
  final WorkoutRepository _workoutRepository;
  final ProfileLocalDataSource _profileLocalDataSource;
  final GamificationEngine _engine;

  Future<GamificationSyncResult> syncAfterWorkout() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    final preferences = await _profileLocalDataSource.getPreferences();
    return _engine.sync(workouts: workouts, preferences: preferences);
  }

  Future<GamificationSyncResult> refresh() => syncAfterWorkout();

  Future<List<Achievement>> getAchievements() async {
    await syncAfterWorkout();
    return _localDataSource.getAchievements();
  }

  Future<List<Goal>> getGoals() async {
    final result = await syncAfterWorkout();
    return result.goals;
  }

  Future<List<Challenge>> getChallenges() async {
    final result = await syncAfterWorkout();
    return result.challenges;
  }

  Future<GamificationStats> getStats() async {
    final result = await syncAfterWorkout();
    return result.stats;
  }

  Future<List<Milestone>> getMilestones() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    final totalDistanceKm = workouts.fold<double>(
          0,
          (total, workout) => total + workout.distanceInMeters,
        ) /
        1000;
    return _engine.buildMilestones(totalDistanceKm);
  }
}
