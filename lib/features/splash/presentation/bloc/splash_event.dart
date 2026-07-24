part of 'splash_bloc.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the splash screen mounts.
final class SplashStarted extends SplashEvent {
  const SplashStarted();
}

/// Triggered when the logo animation completes.
final class SplashAnimationCompleted extends SplashEvent {
  const SplashAnimationCompleted();
}
