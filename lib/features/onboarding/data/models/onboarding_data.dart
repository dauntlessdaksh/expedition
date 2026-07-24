import 'package:equatable/equatable.dart';

import 'activity_level.dart';
import 'fitness_goal.dart';
import 'gender.dart';

/// Collected onboarding fields persisted after the flow completes.
class OnboardingData extends Equatable {
  const OnboardingData({
    this.name = '',
    this.gender,
    this.age = 25,
    this.height = 170,
    this.weight = 70,
    this.fitnessGoal,
    this.activityLevel,
  });

  final String name;
  final Gender? gender;
  final int age;
  final double height;
  final double weight;
  final FitnessGoal? fitnessGoal;
  final ActivityLevel? activityLevel;

  bool get isComplete =>
      name.trim().isNotEmpty &&
      gender != null &&
      fitnessGoal != null &&
      activityLevel != null;

  OnboardingData copyWith({
    String? name,
    Gender? gender,
    int? age,
    double? height,
    double? weight,
    FitnessGoal? fitnessGoal,
    ActivityLevel? activityLevel,
  }) {
    return OnboardingData(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  @override
  List<Object?> get props => [
        name,
        gender,
        age,
        height,
        weight,
        fitnessGoal,
        activityLevel,
      ];
}
