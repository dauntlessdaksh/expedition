import '../datasource/onboarding_local_datasource.dart';
import '../models/onboarding_data.dart';
import '../models/user_profile.dart';

/// Repository for onboarding persistence operations.
class OnboardingRepository {
  const OnboardingRepository(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  Future<bool> hasCompletedOnboarding() =>
      _localDataSource.hasCompletedOnboarding();

  Future<UserProfile?> getUserProfile() => _localDataSource.getUserProfile();

  Future<UserProfile> saveOnboardingData(OnboardingData data) =>
      _localDataSource.saveOnboardingData(data);
}
