part of 'avatar_bloc.dart';

enum AvatarStatus {
  initial,
  loading,
  ready,
  validationError,
  submitting,
  success,
  failure,
}

final class AvatarState extends Equatable {
  const AvatarState({
    this.userId,
    this.gender,
    this.hairStyle,
    this.skinTone,
    this.outfitColor,
    this.status = AvatarStatus.initial,
  });

  final int? userId;
  final String? gender;
  final String? hairStyle;
  final String? skinTone;
  final String? outfitColor;
  final AvatarStatus status;

  AvatarState copyWith({
    int? userId,
    String? gender,
    String? hairStyle,
    String? skinTone,
    String? outfitColor,
    AvatarStatus? status,
  }) {
    return AvatarState(
      userId: userId ?? this.userId,
      gender: gender ?? this.gender,
      hairStyle: hairStyle ?? this.hairStyle,
      skinTone: skinTone ?? this.skinTone,
      outfitColor: outfitColor ?? this.outfitColor,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        gender,
        hairStyle,
        skinTone,
        outfitColor,
        status,
      ];
}
