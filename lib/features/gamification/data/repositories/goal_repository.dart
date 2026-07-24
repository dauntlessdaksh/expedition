import '../../domain/models/goal.dart';
import 'gamification_repository.dart';

/// Goal tracking APIs backed by persisted gamification state.
class GoalRepository {
  const GoalRepository(this._gamificationRepository);

  final GamificationRepository _gamificationRepository;

  Future<List<Goal>> getGoals() {
    return _gamificationRepository.getGoals();
  }
}
