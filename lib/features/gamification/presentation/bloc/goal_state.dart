part of 'goal_bloc.dart';

enum GoalStatus {
  initial,
  loading,
  loaded,
  failure,
}

final class GoalState extends Equatable {
  const GoalState({
    this.status = GoalStatus.initial,
    this.goals = const [],
  });

  final GoalStatus status;
  final List<Goal> goals;

  GoalState copyWith({
    GoalStatus? status,
    List<Goal>? goals,
  }) {
    return GoalState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
    );
  }

  @override
  List<Object?> get props => [status, goals];
}
