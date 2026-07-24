import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/activity_level.dart';
import '../../data/models/fitness_goal.dart';
import '../../data/models/gender.dart';
import '../../data/models/onboarding_data.dart';
import '../../data/repositories/onboarding_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// Manages the multi-step onboarding flow and persistence.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({required OnboardingRepository repository})
      : _repository = repository,
        super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingBackPressed>(_onBackPressed);
    on<OnboardingNameChanged>(_onNameChanged);
    on<OnboardingGenderSelected>(_onGenderSelected);
    on<OnboardingAgeChanged>(_onAgeChanged);
    on<OnboardingHeightChanged>(_onHeightChanged);
    on<OnboardingWeightChanged>(_onWeightChanged);
    on<OnboardingFitnessGoalSelected>(_onFitnessGoalSelected);
    on<OnboardingActivityLevelSelected>(_onActivityLevelSelected);
    on<OnboardingFinished>(_onFinished);
    on<OnboardingNavigationHandled>(_onNavigationHandled);
  }

  final OnboardingRepository _repository;

  void _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(status: OnboardingStatus.inProgress));
  }

  void _onNextPressed(OnboardingNextPressed event, Emitter<OnboardingState> emit) {
    final error = _validateCurrentStep();
    if (error != null) {
      emit(state.copyWith(validationError: error));
      return;
    }

    emit(state.copyWith(clearValidationError: true));

    if (state.currentStep == OnboardingStep.permissions) {
      add(const OnboardingFinished());
      return;
    }

    final nextStep = state.currentStep.next;
    if (nextStep != null) {
      emit(state.copyWith(currentStep: nextStep));
    }
  }

  void _onBackPressed(OnboardingBackPressed event, Emitter<OnboardingState> emit) {
    final previous = state.currentStep.previous;
    if (previous != null) {
      emit(state.copyWith(
        currentStep: previous,
        clearValidationError: true,
      ));
    }
  }

  void _onNameChanged(OnboardingNameChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(
      data: state.data.copyWith(name: event.name),
      clearValidationError: true,
    ));
  }

  void _onGenderSelected(
    OnboardingGenderSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      data: state.data.copyWith(gender: event.gender),
      clearValidationError: true,
    ));
  }

  void _onAgeChanged(OnboardingAgeChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(data: state.data.copyWith(age: event.age)));
  }

  void _onHeightChanged(
    OnboardingHeightChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(data: state.data.copyWith(height: event.height)));
  }

  void _onWeightChanged(
    OnboardingWeightChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(data: state.data.copyWith(weight: event.weight)));
  }

  void _onFitnessGoalSelected(
    OnboardingFitnessGoalSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      data: state.data.copyWith(fitnessGoal: event.goal),
      clearValidationError: true,
    ));
  }

  void _onActivityLevelSelected(
    OnboardingActivityLevelSelected event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      data: state.data.copyWith(activityLevel: event.level),
      clearValidationError: true,
    ));
  }

  Future<void> _onFinished(
    OnboardingFinished event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.data.isComplete) {
      emit(state.copyWith(
        validationError: 'Please complete all onboarding steps.',
      ));
      return;
    }

    emit(state.copyWith(
      status: OnboardingStatus.submitting,
      clearValidationError: true,
    ));

    try {
      await _repository.saveOnboardingData(state.data);
      emit(state.copyWith(status: OnboardingStatus.completed));
    } on Exception {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        validationError: 'Unable to save your profile. Please try again.',
      ));
    }
  }

  void _onNavigationHandled(
    OnboardingNavigationHandled event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(status: OnboardingStatus.inProgress));
  }

  String? _validateCurrentStep() {
    switch (state.currentStep) {
      case OnboardingStep.welcome:
        return null;
      case OnboardingStep.name:
        if (state.data.name.trim().isEmpty) {
          return 'Please enter your first name';
        }
        return null;
      case OnboardingStep.gender:
        if (state.data.gender == null) {
          return 'Please select your gender';
        }
        return null;
      case OnboardingStep.age:
      case OnboardingStep.height:
      case OnboardingStep.weight:
        return null;
      case OnboardingStep.fitnessGoal:
        if (state.data.fitnessGoal == null) {
          return 'Please select a fitness goal';
        }
        return null;
      case OnboardingStep.activityLevel:
        if (state.data.activityLevel == null) {
          return 'Please select your activity level';
        }
        return null;
      case OnboardingStep.permissions:
        return null;
    }
  }
}
