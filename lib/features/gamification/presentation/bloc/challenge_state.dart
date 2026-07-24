part of 'challenge_bloc.dart';

enum ChallengeStatus {
  initial,
  loading,
  loaded,
  failure,
}

final class ChallengeState extends Equatable {
  const ChallengeState({
    this.status = ChallengeStatus.initial,
    this.challenges = const [],
  });

  final ChallengeStatus status;
  final List<Challenge> challenges;

  ChallengeState copyWith({
    ChallengeStatus? status,
    List<Challenge>? challenges,
  }) {
    return ChallengeState(
      status: status ?? this.status,
      challenges: challenges ?? this.challenges,
    );
  }

  @override
  List<Object?> get props => [status, challenges];
}
