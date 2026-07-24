part of 'history_bloc.dart';

enum HistoryStatus {
  initial,
  loading,
  loaded,
  empty,
  failure,
  deleting,
}

final class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.allWorkouts = const [],
    this.visibleWorkouts = const [],
    this.searchQuery = '',
    this.filter = HistoryFilter.allTime,
    this.sort = HistorySort.newestFirst,
    this.errorMessage,
    this.deletedWorkoutId,
    this.focusedWorkout,
  });

  final HistoryStatus status;
  final List<Workout> allWorkouts;
  final List<Workout> visibleWorkouts;
  final String searchQuery;
  final HistoryFilter filter;
  final HistorySort sort;
  final String? errorMessage;
  final int? deletedWorkoutId;
  final Workout? focusedWorkout;

  bool get hasWorkouts => allWorkouts.isNotEmpty;
  bool get hasVisibleWorkouts => visibleWorkouts.isNotEmpty;

  HistoryState copyWith({
    HistoryStatus? status,
    List<Workout>? allWorkouts,
    List<Workout>? visibleWorkouts,
    String? searchQuery,
    HistoryFilter? filter,
    HistorySort? sort,
    String? errorMessage,
    int? deletedWorkoutId,
    Workout? focusedWorkout,
    bool clearDeletedWorkoutId = false,
    bool clearFocusedWorkout = false,
    bool clearError = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      allWorkouts: allWorkouts ?? this.allWorkouts,
      visibleWorkouts: visibleWorkouts ?? this.visibleWorkouts,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      deletedWorkoutId: clearDeletedWorkoutId
          ? null
          : deletedWorkoutId ?? this.deletedWorkoutId,
      focusedWorkout: clearFocusedWorkout
          ? null
          : focusedWorkout ?? this.focusedWorkout,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allWorkouts,
        visibleWorkouts,
        searchQuery,
        filter,
        sort,
        errorMessage,
        deletedWorkoutId,
        focusedWorkout,
      ];
}
