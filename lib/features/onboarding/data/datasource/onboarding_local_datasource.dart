import '../../../../core/database/app_database.dart';
import '../models/onboarding_data.dart';
import '../models/user_profile.dart';

/// Data source for persisting onboarding results via Drift.
class OnboardingLocalDataSource {
  const OnboardingLocalDataSource(this._database);

  final AppDatabase _database;

  Future<bool> hasCompletedOnboarding() async {
    final users = await _database.select(_database.users).get();
    return users.isNotEmpty;
  }

  Future<UserProfile?> getUserProfile() async {
    final user = await (_database.select(_database.users)
          ..limit(1))
        .getSingleOrNull();

    if (user == null) return null;

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

  Future<UserProfile> saveOnboardingData(OnboardingData data) async {
    final id = await _database.into(_database.users).insert(
          UsersCompanion.insert(
            name: data.name.trim(),
            gender: data.gender!.storageValue,
            age: data.age,
            height: data.height,
            weight: data.weight,
            fitnessGoal: data.fitnessGoal!.storageValue,
            activityLevel: data.activityLevel!.storageValue,
          ),
        );

    final existingSettings = await (_database.select(_database.settings)
          ..limit(1))
        .getSingleOrNull();

    if (existingSettings == null) {
      await _database.into(_database.settings).insert(
            const SettingsCompanion(),
          );
    }

    final user = await (_database.select(_database.users)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();

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
}
