part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

final class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

final class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

final class OnboardingBackPressed extends OnboardingEvent {
  const OnboardingBackPressed();
}

final class OnboardingNameChanged extends OnboardingEvent {
  const OnboardingNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class OnboardingGenderSelected extends OnboardingEvent {
  const OnboardingGenderSelected(this.gender);

  final Gender gender;

  @override
  List<Object?> get props => [gender];
}

final class OnboardingAgeChanged extends OnboardingEvent {
  const OnboardingAgeChanged(this.age);

  final int age;

  @override
  List<Object?> get props => [age];
}

final class OnboardingHeightChanged extends OnboardingEvent {
  const OnboardingHeightChanged(this.height);

  final double height;

  @override
  List<Object?> get props => [height];
}

final class OnboardingWeightChanged extends OnboardingEvent {
  const OnboardingWeightChanged(this.weight);

  final double weight;

  @override
  List<Object?> get props => [weight];
}

final class OnboardingFitnessGoalSelected extends OnboardingEvent {
  const OnboardingFitnessGoalSelected(this.goal);

  final FitnessGoal goal;

  @override
  List<Object?> get props => [goal];
}

final class OnboardingActivityLevelSelected extends OnboardingEvent {
  const OnboardingActivityLevelSelected(this.level);

  final ActivityLevel level;

  @override
  List<Object?> get props => [level];
}

final class OnboardingFinished extends OnboardingEvent {
  const OnboardingFinished();
}

final class OnboardingNavigationHandled extends OnboardingEvent {
  const OnboardingNavigationHandled();
}
