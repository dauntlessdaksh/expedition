import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Manages onboarding page state and navigation triggers.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingSkipPressed>(_onSkipPressed);
    on<OnboardingGetStartedPressed>(_onGetStarted);
    on<OnboardingNavigationHandled>(_onNavigationHandled);
  }

  static const int totalPages = 3;

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentPage < totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void _onSkipPressed(
    OnboardingSkipPressed event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(navigationTarget: OnboardingNavigation.profile));
  }

  void _onGetStarted(
    OnboardingGetStartedPressed event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(navigationTarget: OnboardingNavigation.profile));
  }

  void _onNavigationHandled(
    OnboardingNavigationHandled event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(clearNavigation: true));
  }
}
