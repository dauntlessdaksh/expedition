import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/achievement_repository.dart';
import '../../domain/models/gamification_models.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

/// Loads and refreshes achievement progress.
class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  AchievementBloc({required AchievementRepository repository})
      : _repository = repository,
        super(const AchievementState()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<RefreshAchievements>(_onRefreshAchievements);
  }

  final AchievementRepository _repository;

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    emit(state.copyWith(status: AchievementStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshAchievements(
    RefreshAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    await _load(emit, isRefresh: true);
  }

  Future<void> _load(
    Emitter<AchievementState> emit, {
    bool isRefresh = false,
  }) async {
    if (!isRefresh && state.status != AchievementStatus.loading) {
      emit(state.copyWith(status: AchievementStatus.loading));
    }

    try {
      final achievements = await _repository.getAchievements();
      emit(state.copyWith(
        status: AchievementStatus.loaded,
        achievements: achievements,
      ));
    } on Exception {
      emit(state.copyWith(status: AchievementStatus.failure));
    }
  }
}
