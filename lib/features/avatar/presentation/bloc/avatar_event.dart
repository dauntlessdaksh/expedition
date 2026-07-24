part of 'avatar_bloc.dart';

sealed class AvatarEvent extends Equatable {
  const AvatarEvent();

  @override
  List<Object?> get props => [];
}

final class AvatarLoadRequested extends AvatarEvent {
  const AvatarLoadRequested();
}

final class AvatarGenderSelected extends AvatarEvent {
  const AvatarGenderSelected(this.gender);

  final String gender;

  @override
  List<Object?> get props => [gender];
}

final class AvatarHairStyleSelected extends AvatarEvent {
  const AvatarHairStyleSelected(this.hairStyle);

  final String hairStyle;

  @override
  List<Object?> get props => [hairStyle];
}

final class AvatarSkinToneSelected extends AvatarEvent {
  const AvatarSkinToneSelected(this.skinTone);

  final String skinTone;

  @override
  List<Object?> get props => [skinTone];
}

final class AvatarOutfitColorSelected extends AvatarEvent {
  const AvatarOutfitColorSelected(this.outfitColor);

  final String outfitColor;

  @override
  List<Object?> get props => [outfitColor];
}

final class AvatarSubmitted extends AvatarEvent {
  const AvatarSubmitted();
}

final class AvatarNavigationHandled extends AvatarEvent {
  const AvatarNavigationHandled();
}
