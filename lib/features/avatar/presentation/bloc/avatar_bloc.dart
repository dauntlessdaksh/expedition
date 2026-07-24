import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/data/repositories/user_repository.dart';
import '../../data/models/avatar_options.dart';

part 'avatar_event.dart';
part 'avatar_state.dart';

/// Manages avatar customization and persistence.
class AvatarBloc extends Bloc<AvatarEvent, AvatarState> {
  AvatarBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const AvatarState()) {
    on<AvatarLoadRequested>(_onLoadRequested);
    on<AvatarGenderSelected>(_onGenderSelected);
    on<AvatarHairStyleSelected>(_onHairStyleSelected);
    on<AvatarSkinToneSelected>(_onSkinToneSelected);
    on<AvatarOutfitColorSelected>(_onOutfitColorSelected);
    on<AvatarSubmitted>(_onSubmitted);
    on<AvatarNavigationHandled>(_onNavigationHandled);
  }

  final UserRepository _userRepository;

  Future<void> _onLoadRequested(
    AvatarLoadRequested event,
    Emitter<AvatarState> emit,
  ) async {
    emit(state.copyWith(status: AvatarStatus.loading));

    final user = await _userRepository.getUser();
    if (user == null) {
      emit(state.copyWith(status: AvatarStatus.failure));
      return;
    }

    emit(state.copyWith(
      status: AvatarStatus.ready,
      userId: user.id,
      gender: user.gender,
      hairStyle: user.hairStyle ?? AvatarOptions.hairStyles.first,
      skinTone: user.skinTone ?? AvatarOptions.skinTones.first,
      outfitColor: user.outfitColor ?? AvatarOptions.outfitColors.first,
    ));
  }

  void _onGenderSelected(
    AvatarGenderSelected event,
    Emitter<AvatarState> emit,
  ) {
    emit(state.copyWith(gender: event.gender));
  }

  void _onHairStyleSelected(
    AvatarHairStyleSelected event,
    Emitter<AvatarState> emit,
  ) {
    emit(state.copyWith(hairStyle: event.hairStyle));
  }

  void _onSkinToneSelected(
    AvatarSkinToneSelected event,
    Emitter<AvatarState> emit,
  ) {
    emit(state.copyWith(skinTone: event.skinTone));
  }

  void _onOutfitColorSelected(
    AvatarOutfitColorSelected event,
    Emitter<AvatarState> emit,
  ) {
    emit(state.copyWith(outfitColor: event.outfitColor));
  }

  Future<void> _onSubmitted(
    AvatarSubmitted event,
    Emitter<AvatarState> emit,
  ) async {
    if (state.userId == null ||
        state.gender == null ||
        state.hairStyle == null ||
        state.skinTone == null ||
        state.outfitColor == null) {
      emit(state.copyWith(status: AvatarStatus.validationError));
      return;
    }

    emit(state.copyWith(status: AvatarStatus.submitting));

    try {
      await _userRepository.updateAvatar(
        userId: state.userId!,
        gender: state.gender!,
        hairStyle: state.hairStyle!,
        skinTone: state.skinTone!,
        outfitColor: state.outfitColor!,
      );

      emit(state.copyWith(status: AvatarStatus.success));
    } on Exception {
      emit(state.copyWith(status: AvatarStatus.failure));
    }
  }

  void _onNavigationHandled(
    AvatarNavigationHandled event,
    Emitter<AvatarState> emit,
  ) {
    emit(state.copyWith(status: AvatarStatus.ready));
  }
}
