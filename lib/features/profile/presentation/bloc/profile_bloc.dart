import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/profile_repository.dart';
import '../../domain/models/profile_data.dart';
import '../../domain/models/profile_models.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Loads and updates profile, preferences, and workout data actions.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteAllWorkouts>(_onDeleteAllWorkouts);
    on<UpdatePreferences>(_onUpdatePreferences);
    on<ExportWorkouts>(_onExportWorkouts);
    on<ClearProfileMessage>(_onClearProfileMessage);
  }

  final ProfileRepository _repository;

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(
      status: ProfileStatus.loading,
      clearMessage: true,
      clearExportResult: true,
    ));

    try {
      final data = await _repository.getProfileData();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        data: data,
      ));
    } on Exception {
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessage: true));

    try {
      final data = await _repository.updateProfile(event.request);
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        data: data,
        isSaving: false,
        message: 'Profile updated.',
      ));
    } on Exception {
      emit(state.copyWith(
        isSaving: false,
        message: 'Unable to update profile.',
      ));
    }
  }

  Future<void> _onUpdatePreferences(
    UpdatePreferences event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessage: true));

    try {
      final data = await _repository.updatePreferences(event.request);
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        data: data,
        isSaving: false,
        message: 'Preferences saved.',
      ));
    } on Exception {
      emit(state.copyWith(
        isSaving: false,
        message: 'Unable to save preferences.',
      ));
    }
  }

  Future<void> _onDeleteAllWorkouts(
    DeleteAllWorkouts event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessage: true));

    try {
      await _repository.deleteAllWorkouts();
      final data = await _repository.getProfileData();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        data: data,
        isSaving: false,
        message: 'All workouts deleted.',
      ));
    } on Exception {
      emit(state.copyWith(
        isSaving: false,
        message: 'Unable to delete workouts.',
      ));
    }
  }

  Future<void> _onExportWorkouts(
    ExportWorkouts event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearMessage: true, clearExportResult: true));

    try {
      final result = await _repository.exportWorkouts();
      final data = await _repository.getProfileData();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        data: data,
        isSaving: false,
        exportResult: result,
        message: result.workoutCount == 0
            ? 'No workouts to export.'
            : 'Exported ${result.workoutCount} workouts.',
      ));
    } on Exception {
      emit(state.copyWith(
        isSaving: false,
        message: 'Unable to export workouts.',
      ));
    }
  }

  void _onClearProfileMessage(
    ClearProfileMessage event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(clearMessage: true, clearExportResult: true));
  }
}
