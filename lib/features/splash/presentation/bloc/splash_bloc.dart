import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../onboarding/data/repositories/onboarding_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

/// Handles splash initialization and routing decisions.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc({required OnboardingRepository onboardingRepository})
      : _onboardingRepository = onboardingRepository,
        super(const SplashState()) {
    on<SplashStarted>(_onStarted);
    on<SplashAnimationCompleted>(_onAnimationCompleted);
  }

  final OnboardingRepository _onboardingRepository;

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(status: SplashStatus.initializing));

    final hasCompleted =
        await _onboardingRepository.hasCompletedOnboarding();
    final destination = hasCompleted
        ? SplashDestination.home
        : SplashDestination.onboarding;

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
