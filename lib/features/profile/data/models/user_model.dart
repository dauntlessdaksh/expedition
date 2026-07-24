import 'package:equatable/equatable.dart';

/// Domain model representing a local user profile.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    this.hairStyle,
    this.skinTone,
    this.outfitColor,
    required this.createdAt,
  });

  final int id;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final double height;
  final double weight;
  final String? hairStyle;
  final String? skinTone;
  final String? outfitColor;
  final DateTime createdAt;

  bool get hasAvatar =>
      hairStyle != null && skinTone != null && outfitColor != null;

  UserModel copyWith({
    int? id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? hairStyle,
    String? skinTone,
    String? outfitColor,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      hairStyle: hairStyle ?? this.hairStyle,
      skinTone: skinTone ?? this.skinTone,
      outfitColor: outfitColor ?? this.outfitColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dateOfBirth,
        gender,
        height,
        weight,
        hairStyle,
        skinTone,
        outfitColor,
        createdAt,
      ];
}
