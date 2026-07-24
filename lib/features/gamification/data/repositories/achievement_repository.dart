import '../../domain/models/gamification_models.dart';
import 'gamification_repository.dart';

/// Achievement read APIs backed by persisted gamification state.
class AchievementRepository {
  const AchievementRepository(this._gamificationRepository);

  final GamificationRepository _gamificationRepository;

  Future<List<Achievement>> getAchievements() {
    return _gamificationRepository.getAchievements();
  }

  Future<GamificationSyncResult> syncAfterWorkout() {
    return _gamificationRepository.syncAfterWorkout();
  }
}
