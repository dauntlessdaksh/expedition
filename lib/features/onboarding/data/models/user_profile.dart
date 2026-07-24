import 'package:equatable/equatable.dart';

import '../models/onboarding_data.dart';

/// Domain model representing a persisted user profile.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.activityLevel,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String gender;
  final int age;
  final double height;
  final double weight;
  final String fitnessGoal;
  final String activityLevel;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        name,
        gender,
        age,
        height,
        weight,
        fitnessGoal,
        activityLevel,
        createdAt,
      ];
}

extension OnboardingDataMapper on OnboardingData {
  UserProfile toProfile({
    required int id,
    required DateTime createdAt,
  }) {
    return UserProfile(
      id: id,
      name: name.trim(),
      gender: gender!.storageValue,
      age: age,
      height: height,
      weight: weight,
      fitnessGoal: fitnessGoal!.storageValue,
      activityLevel: activityLevel!.storageValue,
      createdAt: createdAt,
    );
  }
}
