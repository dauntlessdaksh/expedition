import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../onboarding/data/models/user_profile.dart';
import '../../domain/models/profile_models.dart';

/// Drift-backed persistence for profile and settings data.
class ProfileLocalDataSource {
  const ProfileLocalDataSource(this._database);

  final AppDatabase _database;

  Future<UserProfile?> getUserProfile() async {
    final user = await (_database.select(_database.users)..limit(1))
        .getSingleOrNull();

    if (user == null) {
      return null;
    }

    return UserProfile(
      id: user.id,
      name: user.name,
      gender: user.gender,
      age: user.age,
      height: user.height,
      weight: user.weight,
      fitnessGoal: user.fitnessGoal,
      activityLevel: user.activityLevel,
      createdAt: user.createdAt,
    );
  }

  Future<UserProfile> updateUserProfile({
    required int id,
    required String name,
    required String gender,
    required int age,
    required double height,
    required double weight,
    required String fitnessGoal,
    required String activityLevel,
  }) async {
    await (_database.update(_database.users)..where((tbl) => tbl.id.equals(id)))
        .write(
      UsersCompanion(
        name: Value(name.trim()),
        gender: Value(gender),
        age: Value(age),
        height: Value(height),
        weight: Value(weight),
        fitnessGoal: Value(fitnessGoal),
        activityLevel: Value(activityLevel),
      ),
    );

    final updated = await getUserProfile();
    return updated!;
  }

  Future<UserPreferences> getPreferences() async {
    var settings = await (_database.select(_database.settings)..limit(1))
        .getSingleOrNull();

    if (settings == null) {
      await _database.into(_database.settings).insert(
            const SettingsCompanion(),
          );
      settings = await (_database.select(_database.settings)..limit(1))
          .getSingle();
    }

    final preferences = UserPreferences.fromRow(settings);
    return _normalizeLegacyGoals(preferences, settings.id);
  }

  Future<UserPreferences> _normalizeLegacyGoals(
    UserPreferences preferences,
    int settingsId,
  ) async {
    var dailyDistanceKm = preferences.weeklyDistanceGoalKm;
    var dailyCalories = preferences.weeklyWorkoutGoal;
    var needsUpdate = false;

    // Older builds stored weekly distance (e.g. 56 km/week).
    if (dailyDistanceKm > 25) {
      dailyDistanceKm = (dailyDistanceKm / 7).clamp(1.0, 30.0);
      needsUpdate = true;
    }

    // Older builds stored weekly workout count (e.g. 12 workouts/week).
    if (dailyCalories < 100) {
      dailyCalories = 600;
      needsUpdate = true;
    }

    if (!needsUpdate) {
      return preferences;
    }

    final normalized = preferences.copyWith(
      weeklyDistanceGoalKm: dailyDistanceKm,
      weeklyWorkoutGoal: dailyCalories,
    );

    await (_database.update(_database.settings)
          ..where((tbl) => tbl.id.equals(settingsId)))
        .write(
      SettingsCompanion(
        weeklyDistanceGoal: Value(dailyDistanceKm),
        weeklyWorkoutGoal: Value(dailyCalories),
      ),
    );

    return normalized;
  }

  Future<UserPreferences> updatePreferences(
    PreferencesUpdateRequest request,
  ) async {
    final current = await getPreferences();
    final next = current.copyWith(
      unit: request.unit,
      theme: request.theme,
      notificationsEnabled: request.notificationsEnabled,
      dailyStepGoal: request.dailyStepGoal,
      weeklyDistanceGoalKm:
          request.dailyDistanceGoalKm ?? request.weeklyDistanceGoalKm,
      weeklyWorkoutGoal:
          request.dailyCalorieGoal ?? request.weeklyWorkoutGoal,
    );

    final existing = await (_database.select(_database.settings)..limit(1))
        .getSingleOrNull();

    if (existing == null) {
      await _database.into(_database.settings).insert(
            SettingsCompanion(
              unit: Value(next.unit),
              theme: Value(next.theme),
              notificationsEnabled: Value(next.notificationsEnabled),
              dailyStepGoal: Value(next.dailyStepGoal),
              weeklyDistanceGoal: Value(next.weeklyDistanceGoalKm),
              weeklyWorkoutGoal: Value(next.weeklyWorkoutGoal),
              dailyActiveMinutesGoal: Value(next.dailyActiveMinutesGoal),
              monthlyWorkoutGoal: Value(next.monthlyWorkoutGoal),
            ),
          );
    } else {
      await (_database.update(_database.settings)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        SettingsCompanion(
          unit: Value(next.unit),
          theme: Value(next.theme),
          notificationsEnabled: Value(next.notificationsEnabled),
          dailyStepGoal: Value(next.dailyStepGoal),
          weeklyDistanceGoal: Value(next.weeklyDistanceGoalKm),
          weeklyWorkoutGoal: Value(next.weeklyWorkoutGoal),
          dailyActiveMinutesGoal: Value(next.dailyActiveMinutesGoal),
          monthlyWorkoutGoal: Value(next.monthlyWorkoutGoal),
        ),
      );
    }

    return next;
  }
}
