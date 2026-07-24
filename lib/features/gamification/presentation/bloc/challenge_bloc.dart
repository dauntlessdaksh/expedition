import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/challenge_repository.dart';
import '../../domain/models/goal.dart';

part 'challenge_event.dart';
part 'challenge_state.dart';

/// Loads and refreshes active challenges.
class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  ChallengeBloc({required ChallengeRepository repository})
      : _repository = repository,
        super(const ChallengeState()) {
    on<LoadChallenges>(_onLoadChallenges);
    on<RefreshChallenges>(_onRefreshChallenges);
  }

  final ChallengeRepository _repository;

  Future<void> _onLoadChallenges(
    LoadChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(state.copyWith(status: ChallengeStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshChallenges(
    RefreshChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    await _load(emit, isRefresh: true);
  }

  Future<void> _load(
    Emitter<ChallengeState> emit, {
    bool isRefresh = false,
  }) async {
    if (!isRefresh && state.status != ChallengeStatus.loading) {
      emit(state.copyWith(status: ChallengeStatus.loading));
    }

    try {
      final challenges = await _repository.getChallenges();
      emit(state.copyWith(
        status: ChallengeStatus.loaded,
        challenges: challenges,
      ));
    } on Exception {
      emit(state.copyWith(status: ChallengeStatus.failure));
    }
  }
}
