part of 'goal_bloc.dart';

sealed class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

final class LoadGoals extends GoalEvent {
  const LoadGoals();
}

final class RefreshGoals extends GoalEvent {
  const RefreshGoals();
}
