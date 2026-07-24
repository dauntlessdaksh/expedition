part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  failure,
}

final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.data,
    this.isSaving = false,
    this.message,
    this.exportResult,
  });

  final ProfileStatus status;
  final ProfileData? data;
  final bool isSaving;
  final String? message;
  final WorkoutExportResult? exportResult;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileData? data,
    bool? isSaving,
    String? message,
    WorkoutExportResult? exportResult,
    bool clearMessage = false,
    bool clearExportResult = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      isSaving: isSaving ?? this.isSaving,
      message: clearMessage ? null : message ?? this.message,
      exportResult:
          clearExportResult ? null : exportResult ?? this.exportResult,
    );
  }

  @override
  List<Object?> get props => [
        status,
        data,
        isSaving,
        message,
        exportResult,
      ];
}
