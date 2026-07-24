part of 'activity_bloc.dart';

sealed class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

final class ActivityStarted extends ActivityEvent {
  const ActivityStarted();
}

final class ActivityPreviewStopped extends ActivityEvent {
  const ActivityPreviewStopped();
}

final class StartTracking extends ActivityEvent {
  const StartTracking();
}

final class PauseTracking extends ActivityEvent {
  const PauseTracking();
}

final class ResumeTracking extends ActivityEvent {
  const ResumeTracking();
}

final class StopTracking extends ActivityEvent {
  const StopTracking();
}

final class LocationUpdated extends ActivityEvent {
  const LocationUpdated(this.position);

  final Position position;

  @override
  List<Object?> get props => [position];
}

final class DurationTicked extends ActivityEvent {
  const DurationTicked();
}

final class FollowUserToggled extends ActivityEvent {
  const FollowUserToggled({required this.followUser});

  final bool followUser;

  @override
  List<Object?> get props => [followUser];
}

final class RecenterMapRequested extends ActivityEvent {
  const RecenterMapRequested();
}

final class ClearPendingCelebration extends ActivityEvent {
  const ClearPendingCelebration();
}
