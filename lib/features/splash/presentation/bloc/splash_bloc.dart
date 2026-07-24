import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/data/repositories/user_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

/// Handles splash initialization and routing decisions.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const SplashState()) {
    on<SplashStarted>(_onStarted);
    on<SplashAnimationCompleted>(_onAnimationCompleted);
  }

  final UserRepository _userRepository;

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(status: SplashStatus.initializing));

    final hasUser = await _userRepository.hasUser();
    final destination =
        hasUser ? SplashDestination.home : SplashDestination.onboarding;

    emit(state.copyWith(
      status: SplashStatus.ready,
      destination: destination,
    ));
  }

  void _onAnimationCompleted(
    SplashAnimationCompleted event,
    Emitter<SplashState> emit,
  ) {
    emit(state.copyWith(animationComplete: true));
  }
}
