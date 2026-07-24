part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

final class UpdateProfile extends ProfileEvent {
  const UpdateProfile(this.request);

  final ProfileUpdateRequest request;

  @override
  List<Object?> get props => [request];
}

final class DeleteAllWorkouts extends ProfileEvent {
  const DeleteAllWorkouts();
}

final class UpdatePreferences extends ProfileEvent {
  const UpdatePreferences(this.request);

  final PreferencesUpdateRequest request;

  @override
  List<Object?> get props => [request];
}

final class ExportWorkouts extends ProfileEvent {
  const ExportWorkouts();
}

final class ClearProfileMessage extends ProfileEvent {
  const ClearProfileMessage();
}
