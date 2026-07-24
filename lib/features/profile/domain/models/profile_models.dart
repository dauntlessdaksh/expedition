import 'package:equatable/equatable.dart';

import '../../../../core/database/app_database.dart';
import '../../../onboarding/data/models/activity_level.dart';
import '../../../onboarding/data/models/fitness_goal.dart';
import '../../../onboarding/data/models/gender.dart';

/// Persisted user preferences and workout goals.
class UserPreferences extends Equatable {
  const UserPreferences({
    required this.unit,
    required this.theme,
    required this.notificationsEnabled,
    required this.dailyStepGoal,
    required this.weeklyDistanceGoalKm,
    required this.weeklyWorkoutGoal,
    required this.dailyActiveMinutesGoal,
    required this.monthlyWorkoutGoal,
  });

  final String unit;
  final String theme;
  final bool notificationsEnabled;
  final int dailyStepGoal;
  final double weeklyDistanceGoalKm;
  final int weeklyWorkoutGoal;
  final int dailyActiveMinutesGoal;
  final int monthlyWorkoutGoal;

  bool get usesMetric => unit == 'metric';

  /// Daily calorie goal (stored in [weeklyWorkoutGoal] column).
  int get dailyCalorieGoal => weeklyWorkoutGoal;

  /// Daily distance goal in km (stored in [weeklyDistanceGoalKm] column).
  double get dailyDistanceGoalKm => weeklyDistanceGoalKm;

  factory UserPreferences.fromRow(Setting row) {
    return UserPreferences(
      unit: row.unit,
      theme: row.theme,
      notificationsEnabled: row.notificationsEnabled,
      dailyStepGoal: row.dailyStepGoal,
      weeklyDistanceGoalKm: row.weeklyDistanceGoal,
      weeklyWorkoutGoal: row.weeklyWorkoutGoal,
      dailyActiveMinutesGoal: row.dailyActiveMinutesGoal,
      monthlyWorkoutGoal: row.monthlyWorkoutGoal,
    );
  }

  factory UserPreferences.defaults() {
    return const UserPreferences(
      unit: 'metric',
      theme: 'system',
      notificationsEnabled: true,
      dailyStepGoal: 10000,
      weeklyDistanceGoalKm: 8,
      weeklyWorkoutGoal: 600,
      dailyActiveMinutesGoal: 60,
      monthlyWorkoutGoal: 12,
    );
  }

  UserPreferences copyWith({
    String? unit,
    String? theme,
    bool? notificationsEnabled,
    int? dailyStepGoal,
    double? weeklyDistanceGoalKm,
    int? weeklyWorkoutGoal,
    int? dailyActiveMinutesGoal,
    int? monthlyWorkoutGoal,
  }) {
    return UserPreferences(
      unit: unit ?? this.unit,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      weeklyDistanceGoalKm:
          weeklyDistanceGoalKm ?? this.weeklyDistanceGoalKm,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
      dailyActiveMinutesGoal:
          dailyActiveMinutesGoal ?? this.dailyActiveMinutesGoal,
      monthlyWorkoutGoal: monthlyWorkoutGoal ?? this.monthlyWorkoutGoal,
    );
  }

  @override
  List<Object?> get props => [
        unit,
        theme,
        notificationsEnabled,
        dailyStepGoal,
        weeklyDistanceGoalKm,
        weeklyWorkoutGoal,
        dailyActiveMinutesGoal,
        monthlyWorkoutGoal,
      ];
}

/// Partial update payload for persisted preferences.
class PreferencesUpdateRequest extends Equatable {
  const PreferencesUpdateRequest({
    this.unit,
    this.theme,
    this.notificationsEnabled,
    this.dailyStepGoal,
    this.weeklyDistanceGoalKm,
    this.weeklyWorkoutGoal,
    this.dailyCalorieGoal,
    this.dailyDistanceGoalKm,
  });

  final String? unit;
  final String? theme;
  final bool? notificationsEnabled;
  final int? dailyStepGoal;
  final double? weeklyDistanceGoalKm;
  final int? weeklyWorkoutGoal;
  final int? dailyCalorieGoal;
  final double? dailyDistanceGoalKm;

  @override
  List<Object?> get props => [
        unit,
        theme,
        notificationsEnabled,
        dailyStepGoal,
        weeklyDistanceGoalKm,
        weeklyWorkoutGoal,
        dailyCalorieGoal,
        dailyDistanceGoalKm,
      ];
}

/// Editable personal profile fields.
class ProfileUpdateRequest extends Equatable {
  const ProfileUpdateRequest({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.fitnessGoal,
    required this.activityLevel,
  });

  final String name;
  final int age;
  final double height;
  final double weight;
  final Gender gender;
  final FitnessGoal fitnessGoal;
  final ActivityLevel activityLevel;

  @override
  List<Object?> get props => [
        name,
        age,
        height,
        weight,
        gender,
        fitnessGoal,
        activityLevel,
      ];
}
