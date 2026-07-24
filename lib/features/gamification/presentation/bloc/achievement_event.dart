part of 'achievement_bloc.dart';

sealed class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAchievements extends AchievementEvent {
  const LoadAchievements();
}

final class RefreshAchievements extends AchievementEvent {
  const RefreshAchievements();
}
