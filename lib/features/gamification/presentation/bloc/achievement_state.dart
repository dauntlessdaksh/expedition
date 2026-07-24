part of 'achievement_bloc.dart';

enum AchievementStatus {
  initial,
  loading,
  loaded,
  failure,
}

final class AchievementState extends Equatable {
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.achievements = const [],
  });

  final AchievementStatus status;
  final List<Achievement> achievements;

  AchievementState copyWith({
    AchievementStatus? status,
    List<Achievement>? achievements,
  }) {
    return AchievementState(
      status: status ?? this.status,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  List<Object?> get props => [status, achievements];
}
