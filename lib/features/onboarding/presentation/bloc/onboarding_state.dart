part of 'onboarding_bloc.dart';

enum OnboardingStep {
  welcome,
  name,
  gender,
  age,
  height,
  weight,
  fitnessGoal,
  activityLevel,
  permissions;

  OnboardingStep? get next {
    const steps = OnboardingStep.values;
    final index = steps.indexOf(this);
    if (index >= steps.length - 1) return null;
    return steps[index + 1];
  }

  OnboardingStep? get previous {
    const steps = OnboardingStep.values;
    final index = steps.indexOf(this);
    if (index <= 0) return null;
    return steps[index - 1];
  }

  /// Progress index for the step indicator (0-based, excluding welcome).
  int get progressIndex {
    if (this == OnboardingStep.welcome) return 0;
    return index;
  }

  static const int progressTotal = 8;

  bool get showsProgress => this != OnboardingStep.welcome;
}

enum OnboardingStatus {
  initial,
  inProgress,
  submitting,
  completed,
  failure,
}

final class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.data = const OnboardingData(),
    this.status = OnboardingStatus.initial,
    this.validationError,
  });

  final OnboardingStep currentStep;
  final OnboardingData data;
  final OnboardingStatus status;
  final String? validationError;

  double get progress =>
      currentStep.progressIndex / OnboardingStep.progressTotal;

  bool get canGoBack => currentStep.previous != null;

  String get continueLabel {
    if (currentStep == OnboardingStep.permissions) return 'Get Started';
    if (currentStep == OnboardingStep.welcome) return 'Continue';
    return 'Continue';
  }

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    OnboardingData? data,
    OnboardingStatus? status,
    String? validationError,
    bool clearValidationError = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      status: status ?? this.status,
      validationError:
          clearValidationError ? null : (validationError ?? this.validationError),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        data,
        status,
        validationError,
      ];
}
