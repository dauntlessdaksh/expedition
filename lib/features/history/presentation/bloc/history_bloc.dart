import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/history_repository.dart';
import '../../domain/models/history_filter.dart';
import '../../domain/models/history_sort.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/history_query_engine.dart';

part 'history_event.dart';
part 'history_state.dart';

/// Loads, filters, searches, sorts, and deletes workout history entries.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({required HistoryRepository repository})
      : _repository = repository,
        super(const HistoryState()) {
    on<LoadHistory>(_onLoadHistory);
    on<DeleteWorkout>(_onDeleteWorkout);
    on<SearchWorkout>(_onSearchWorkout);
    on<FilterWorkout>(_onFilterWorkout);
    on<SortWorkout>(_onSortWorkout);
    on<LoadWorkoutDetail>(_onLoadWorkoutDetail);
    on<ClearHistoryMessage>(_onClearHistoryMessage);
  }

  final HistoryRepository _repository;

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(
      status: HistoryStatus.loading,
      clearError: true,
      clearDeletedWorkoutId: true,
    ));

    try {
      final workouts = await _repository.getAllWorkouts();
      _emitWorkouts(emit, workouts);
    } on Exception {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: 'Unable to load workout history.',
      ));
    }
  }

  Future<void> _onDeleteWorkout(
    DeleteWorkout event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.deleting, clearError: true));

    try {
      await _repository.deleteWorkout(event.workoutId);
      final workouts = await _repository.getAllWorkouts();
      _emitWorkouts(
        emit,
        workouts,
        deletedWorkoutId: event.workoutId,
      );
    } on Exception {
      emit(state.copyWith(
        status: HistoryStatus.loaded,
        errorMessage: 'Unable to delete workout.',
      ));
    }
  }

  void _onSearchWorkout(
    SearchWorkout event,
    Emitter<HistoryState> emit,
  ) {
    final nextState = state.copyWith(searchQuery: event.query);
    _emitVisibleWorkouts(emit, nextState);
  }

  void _onFilterWorkout(
    FilterWorkout event,
    Emitter<HistoryState> emit,
  ) {
    final nextState = state.copyWith(filter: event.filter);
    _emitVisibleWorkouts(emit, nextState);
  }

  void _onSortWorkout(
    SortWorkout event,
    Emitter<HistoryState> emit,
  ) {
    final nextState = state.copyWith(sort: event.sort);
    _emitVisibleWorkouts(emit, nextState);
  }

  Future<void> _onLoadWorkoutDetail(
    LoadWorkoutDetail event,
    Emitter<HistoryState> emit,
  ) async {
    for (final workout in state.allWorkouts) {
      if (workout.id == event.workoutId) {
        emit(state.copyWith(focusedWorkout: workout));
        return;
      }
    }

    try {
      final workout = await _repository.getWorkoutById(event.workoutId);
      emit(state.copyWith(focusedWorkout: workout));
    } on Exception {
      emit(state.copyWith(
        errorMessage: 'Unable to load workout details.',
      ));
    }
  }

  void _onClearHistoryMessage(
    ClearHistoryMessage event,
    Emitter<HistoryState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearDeletedWorkoutId: true));
  }

  void _emitWorkouts(
    Emitter<HistoryState> emit,
    List<Workout> workouts, {
    int? deletedWorkoutId,
  }) {
    final nextState = state.copyWith(
      allWorkouts: workouts,
      deletedWorkoutId: deletedWorkoutId,
    );

    if (workouts.isEmpty) {
      emit(nextState.copyWith(
        status: HistoryStatus.empty,
        visibleWorkouts: const [],
      ));
      return;
    }

    _emitVisibleWorkouts(emit, nextState);
  }

  void _emitVisibleWorkouts(
    Emitter<HistoryState> emit,
    HistoryState baseState,
  ) {
    final visible = HistoryQueryEngine.apply(
      workouts: baseState.allWorkouts,
      searchQuery: baseState.searchQuery,
      filter: baseState.filter,
      sort: baseState.sort,
    );

    emit(baseState.copyWith(
      status: visible.isEmpty ? HistoryStatus.empty : HistoryStatus.loaded,
      visibleWorkouts: visible,
    ));
  }
}
