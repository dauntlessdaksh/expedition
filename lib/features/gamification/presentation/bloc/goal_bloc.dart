import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/goal_repository.dart';
import '../../domain/models/goal.dart';

part 'goal_event.dart';
part 'goal_state.dart';

/// Loads and refreshes goal progress bars.
class GoalBloc extends Bloc<GoalEvent, GoalState> {
  GoalBloc({required GoalRepository repository})
      : _repository = repository,
        super(const GoalState()) {
    on<LoadGoals>(_onLoadGoals);
    on<RefreshGoals>(_onRefreshGoals);
  }

  final GoalRepository _repository;

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(status: GoalStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshGoals(
    RefreshGoals event,
    Emitter<GoalState> emit,
  ) async {
    await _load(emit, isRefresh: true);
  }

  Future<void> _load(
    Emitter<GoalState> emit, {
    bool isRefresh = false,
  }) async {
    if (!isRefresh && state.status != GoalStatus.loading) {
      emit(state.copyWith(status: GoalStatus.loading));
    }

    try {
      final goals = await _repository.getGoals();
      emit(state.copyWith(status: GoalStatus.loaded, goals: goals));
    } on Exception {
      emit(state.copyWith(status: GoalStatus.failure));
    }
  }
}
