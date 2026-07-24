import '../../domain/models/goal.dart';
import 'gamification_repository.dart';

/// Challenge APIs backed by persisted gamification state.
class ChallengeRepository {
  const ChallengeRepository(this._gamificationRepository);

  final GamificationRepository _gamificationRepository;

  Future<List<Challenge>> getChallenges() {
    return _gamificationRepository.getChallenges();
  }
}
