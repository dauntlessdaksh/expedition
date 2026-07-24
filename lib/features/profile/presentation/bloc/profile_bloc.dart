import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/data/repositories/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Manages profile form state, validation, and persistence.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const ProfileState()) {
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfileDateOfBirthChanged>(_onDateOfBirthChanged);
    on<ProfileGenderChanged>(_onGenderChanged);
    on<ProfileHeightChanged>(_onHeightChanged);
    on<ProfileWeightChanged>(_onWeightChanged);
    on<ProfileSubmitted>(_onSubmitted);
    on<ProfileNavigationHandled>(_onNavigationHandled);
  }

  final UserRepository _userRepository;

  void _onNameChanged(ProfileNameChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      name: event.name,
      nameError: null,
      status: ProfileStatus.editing,
    ));
  }

  void _onDateOfBirthChanged(
    ProfileDateOfBirthChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      dateOfBirth: event.dateOfBirth,
      dateOfBirthError: null,
      status: ProfileStatus.editing,
    ));
  }

  void _onGenderChanged(
    ProfileGenderChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      gender: event.gender,
      genderError: null,
      status: ProfileStatus.editing,
    ));
  }

  void _onHeightChanged(
    ProfileHeightChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      height: event.height,
      heightError: null,
      status: ProfileStatus.editing,
    ));
  }

  void _onWeightChanged(
    ProfileWeightChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(
      weight: event.weight,
      weightError: null,
      status: ProfileStatus.editing,
    ));
  }

  Future<void> _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    final validation = _validate();
    if (validation != null) {
      emit(validation);
      return;
    }

    emit(state.copyWith(status: ProfileStatus.submitting));

    try {
      await _userRepository.createUser(
        name: state.name.trim(),
        dateOfBirth: state.dateOfBirth!,
        gender: state.gender!,
        height: state.height!,
        weight: state.weight!,
      );

      emit(state.copyWith(status: ProfileStatus.success));
    } on Exception catch (error) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onNavigationHandled(
    ProfileNavigationHandled event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(status: ProfileStatus.editing));
  }

  ProfileState? _validate() {
    String? nameError;
    String? dateOfBirthError;
    String? genderError;
    String? heightError;
    String? weightError;

    if (state.name.trim().isEmpty) {
      nameError = 'Please enter your name';
    } else if (state.name.trim().length < 2) {
      nameError = 'Name must be at least 2 characters';
    }

    if (state.dateOfBirth == null) {
      dateOfBirthError = 'Please select your date of birth';
    } else {
      final age = DateTime.now().difference(state.dateOfBirth!).inDays ~/ 365;
      if (age < 13) {
        dateOfBirthError = 'You must be at least 13 years old';
      }
    }

    if (state.gender == null || state.gender!.isEmpty) {
      genderError = 'Please select your gender';
    }

    if (state.height == null || state.height! <= 0) {
      heightError = 'Please enter a valid height';
    } else if (state.height! < 50 || state.height! > 300) {
      heightError = 'Height must be between 50–300 cm';
    }

    if (state.weight == null || state.weight! <= 0) {
      weightError = 'Please enter a valid weight';
    } else if (state.weight! < 20 || state.weight! > 500) {
      weightError = 'Weight must be between 20–500 kg';
    }

    if (nameError != null ||
        dateOfBirthError != null ||
        genderError != null ||
        heightError != null ||
        weightError != null) {
      return state.copyWith(
        nameError: nameError,
        dateOfBirthError: dateOfBirthError,
        genderError: genderError,
        heightError: heightError,
        weightError: weightError,
        status: ProfileStatus.validationError,
      );
    }

    return null;
  }
}
