import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Provides placeholder dashboard data until real statistics are implemented.
class DummyHomeRepository {
  const DummyHomeRepository({OnboardingRepository? onboardingRepository})
      : _onboardingRepository = onboardingRepository;

  final OnboardingRepository? _onboardingRepository;

  Future<HomeDashboardData> getDashboardData() async {
    final profile = await _onboardingRepository?.getUserProfile();

    return HomeDashboardData(
      userName: profile?.name ?? 'Rachit',
      gender: profile?.gender ?? 'male',
      stats: const DailyStats(
        steps: 6324,
        stepsGoal: 10000,
        calories: 418,
        caloriesGoal: 600,
        distanceKm: 4.2,
        distanceGoalKm: 8.0,
        activeMinutes: 47,
        activeMinutesGoal: 60,
      ),
      streakDays: 14,
      weeklyActivity: const [
        WeeklyActivityDay(label: 'Mon', value: 0.45),
        WeeklyActivityDay(label: 'Tue', value: 0.72),
        WeeklyActivityDay(label: 'Wed', value: 0.58),
        WeeklyActivityDay(label: 'Thu', value: 0.85),
        WeeklyActivityDay(label: 'Fri', value: 0.63),
        WeeklyActivityDay(label: 'Sat', value: 0.92),
        WeeklyActivityDay(label: 'Sun', value: 0.68),
      ],
    );
  }
}
