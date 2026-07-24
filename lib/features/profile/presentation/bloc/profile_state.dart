part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  editing,
  validationError,
  submitting,
  success,
  failure,
}

final class ProfileState extends Equatable {
  const ProfileState({
    this.name = '',
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.nameError,
    this.dateOfBirthError,
    this.genderError,
    this.heightError,
    this.weightError,
    this.status = ProfileStatus.initial,
    this.errorMessage,
  });

  final String name;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final String? nameError;
  final String? dateOfBirthError;
  final String? genderError;
  final String? heightError;
  final String? weightError;
  final ProfileStatus status;
  final String? errorMessage;

  ProfileState copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? nameError,
    String? dateOfBirthError,
    String? genderError,
    String? heightError,
    String? weightError,
    ProfileStatus? status,
    String? errorMessage,
  }) {
    return ProfileState(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      nameError: nameError,
      dateOfBirthError: dateOfBirthError,
      genderError: genderError,
      heightError: heightError,
      weightError: weightError,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        name,
        dateOfBirth,
        gender,
        height,
        weight,
        nameError,
        dateOfBirthError,
        genderError,
        heightError,
        weightError,
        status,
        errorMessage,
      ];
}
