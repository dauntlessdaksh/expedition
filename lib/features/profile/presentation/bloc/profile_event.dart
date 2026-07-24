part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileNameChanged extends ProfileEvent {
  const ProfileNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class ProfileDateOfBirthChanged extends ProfileEvent {
  const ProfileDateOfBirthChanged(this.dateOfBirth);

  final DateTime dateOfBirth;

  @override
  List<Object?> get props => [dateOfBirth];
}

final class ProfileGenderChanged extends ProfileEvent {
  const ProfileGenderChanged(this.gender);

  final String gender;

  @override
  List<Object?> get props => [gender];
}

final class ProfileHeightChanged extends ProfileEvent {
  const ProfileHeightChanged(this.height);

  final double height;

  @override
  List<Object?> get props => [height];
}

final class ProfileWeightChanged extends ProfileEvent {
  const ProfileWeightChanged(this.weight);

  final double weight;

  @override
  List<Object?> get props => [weight];
}

final class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();
}

final class ProfileNavigationHandled extends ProfileEvent {
  const ProfileNavigationHandled();
}
