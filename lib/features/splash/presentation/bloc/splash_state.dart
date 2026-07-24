part of 'splash_bloc.dart';

enum SplashDestination { none, home, onboarding }

enum SplashStatus { initial, initializing, ready }

final class SplashState extends Equatable {
  const SplashState({
    this.status = SplashStatus.initial,
    this.destination = SplashDestination.none,
    this.animationComplete = false,
  });

  final SplashStatus status;
  final SplashDestination destination;
  final bool animationComplete;

  bool get canNavigate =>
      status == SplashStatus.ready &&
      animationComplete &&
      destination != SplashDestination.none;

  SplashState copyWith({
    SplashStatus? status,
    SplashDestination? destination,
    bool? animationComplete,
  }) {
    return SplashState(
      status: status ?? this.status,
      destination: destination ?? this.destination,
      animationComplete: animationComplete ?? this.animationComplete,
    );
  }

  @override
  List<Object?> get props => [status, destination, animationComplete];
}
