part of 'onboarding_bloc.dart';

enum OnboardingNavigation { none, profile }

final class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentPage = 0,
    this.navigationTarget = OnboardingNavigation.none,
  });

  final int currentPage;
  final OnboardingNavigation navigationTarget;

  bool get isLastPage => currentPage == OnboardingBloc.totalPages - 1;

  OnboardingState copyWith({
    int? currentPage,
    OnboardingNavigation? navigationTarget,
    bool clearNavigation = false,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      navigationTarget: clearNavigation
          ? OnboardingNavigation.none
          : (navigationTarget ?? this.navigationTarget),
    );
  }

  @override
  List<Object?> get props => [currentPage, navigationTarget];
}
