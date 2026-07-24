import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../gamification/data/repositories/achievement_repository.dart';
import '../../../history/data/repositories/workout_repository.dart';
import '../../../history/domain/models/workout.dart';
import '../../../onboarding/data/models/activity_level.dart';
import '../../../onboarding/data/models/fitness_goal.dart';
import '../../../onboarding/data/models/gender.dart';
import '../../../shared/utils/polyline_codec.dart';
import '../../../shared/utils/streak_calculator.dart';
import '../../domain/models/profile_data.dart';
import '../../domain/models/profile_models.dart';
import '../datasource/profile_local_datasource.dart';

/// Repository for profile, preferences, achievements, and data management.
class ProfileRepository {
  const ProfileRepository({
    required ProfileLocalDataSource localDataSource,
    required WorkoutRepository workoutRepository,
    required AchievementRepository achievementRepository,
  })  : _localDataSource = localDataSource,
        _workoutRepository = workoutRepository,
        _achievementRepository = achievementRepository;

  final ProfileLocalDataSource _localDataSource;
  final WorkoutRepository _workoutRepository;
  final AchievementRepository _achievementRepository;

  Future<UserPreferences> getPreferences() {
    return _localDataSource.getPreferences();
  }

  Future<ProfileData> getProfileData() async {
    final profile = await _localDataSource.getUserProfile();
    if (profile == null) {
      throw StateError('Profile is unavailable before onboarding completes.');
    }

    final preferences = await _localDataSource.getPreferences();
    final achievements = await _achievementRepository.getAchievements();
    final workouts = await _workoutRepository.getAllWorkouts();
    final streak = StreakCalculator.calculate(
      workouts.map((workout) => workout.startTime),
    );

    return ProfileData(
      profile: profile,
      preferences: preferences,
      currentStreak: streak,
      achievements: achievements
          .map(
            (item) => AchievementBadge(
              id: item.id,
              title: item.title,
              description: item.description,
              isEarned: item.isUnlocked,
            ),
          )
          .toList(),
    );
  }

  Future<ProfileData> updateProfile(ProfileUpdateRequest request) async {
    final current = await _localDataSource.getUserProfile();
    if (current == null) {
      throw StateError('Profile is unavailable before onboarding completes.');
    }

    await _localDataSource.updateUserProfile(
      id: current.id,
      name: request.name,
      gender: request.gender.storageValue,
      age: request.age,
      height: request.height,
      weight: request.weight,
      fitnessGoal: request.fitnessGoal.storageValue,
      activityLevel: request.activityLevel.storageValue,
    );

    return getProfileData();
  }

  Future<ProfileData> updatePreferences(
    PreferencesUpdateRequest request,
  ) async {
    await _localDataSource.updatePreferences(request);
    return getProfileData();
  }

  Future<void> deleteAllWorkouts() async {
    await _workoutRepository.clearAll();
    await _achievementRepository.syncAfterWorkout();
  }

  Future<WorkoutExportResult> exportWorkouts() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    final payload = workouts.map(_workoutToJson).toList();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/expedition_workouts_$timestamp.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );

    return WorkoutExportResult(
      filePath: file.path,
      workoutCount: workouts.length,
    );
  }

  Map<String, Object?> _workoutToJson(Workout workout) {
    return {
      'id': workout.id,
      'activityType': workout.activityType,
      'startTime': workout.startTime.toIso8601String(),
      'endTime': workout.endTime.toIso8601String(),
      'durationInSeconds': workout.durationInSeconds,
      'distanceInMeters': workout.distanceInMeters,
      'averageSpeed': workout.averageSpeed,
      'maxSpeed': workout.maxSpeed,
      'calories': workout.calories,
      'polyline': PolylineCodec.encode(workout.polyline),
      'createdAt': workout.createdAt.toIso8601String(),
    };
  }
}

/// Parses stored enum values back into onboarding models.
abstract final class ProfileValueParser {
  static Gender gender(String value) {
    return Gender.values.firstWhere(
      (gender) => gender.storageValue == value,
      orElse: () => Gender.male,
    );
  }

  static FitnessGoal fitnessGoal(String value) {
    return FitnessGoal.values.firstWhere(
      (goal) => goal.storageValue == value,
      orElse: () => FitnessGoal.stayActive,
    );
  }

  static ActivityLevel activityLevel(String value) {
    return ActivityLevel.values.firstWhere(
      (level) => level.storageValue == value,
      orElse: () => ActivityLevel.beginner,
    );
  }
}
