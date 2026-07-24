part of 'challenge_bloc.dart';

sealed class ChallengeEvent extends Equatable {
  const ChallengeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadChallenges extends ChallengeEvent {
  const LoadChallenges();
}

final class RefreshChallenges extends ChallengeEvent {
  const RefreshChallenges();
}
