part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

final class DeleteWorkout extends HistoryEvent {
  const DeleteWorkout(this.workoutId);

  final int workoutId;

  @override
  List<Object?> get props => [workoutId];
}

final class SearchWorkout extends HistoryEvent {
  const SearchWorkout(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class FilterWorkout extends HistoryEvent {
  const FilterWorkout(this.filter);

  final HistoryFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class SortWorkout extends HistoryEvent {
  const SortWorkout(this.sort);

  final HistorySort sort;

  @override
  List<Object?> get props => [sort];
}

final class LoadWorkoutDetail extends HistoryEvent {
  const LoadWorkoutDetail(this.workoutId);

  final int workoutId;

  @override
  List<Object?> get props => [workoutId];
}

final class ClearHistoryMessage extends HistoryEvent {
  const ClearHistoryMessage();
}
