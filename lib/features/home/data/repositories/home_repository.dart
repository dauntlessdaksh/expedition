import '../../../history/data/repositories/workout_repository.dart';
import '../../../history/domain/models/workout.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../shared/utils/streak_calculator.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Builds home dashboard metrics from persisted workouts and user profile.
class HomeRepository {
  const HomeRepository({
    required WorkoutRepository workoutRepository,
    required OnboardingRepository onboardingRepository,
    required ProfileRepository profileRepository,
  })  : _workoutRepository = workoutRepository,
        _onboardingRepository = onboardingRepository,
        _profileRepository = profileRepository;

  final WorkoutRepository _workoutRepository;
  final OnboardingRepository _onboardingRepository;
  final ProfileRepository _profileRepository;

  static const _defaultCaloriesGoal = 600;
  static const _defaultActiveMinutesGoal = 60;
  static const _stepsPerKm = 1300;

  Future<HomeDashboardData> getDashboardData() async {
    final profile = await _onboardingRepository.getUserProfile();
    final preferences = await _profileRepository.getPreferences();
    final todaysWorkouts = await _workoutRepository.getTodaysWorkouts();
    final weeklyWorkouts = await _workoutRepository.getWeeklyWorkouts();
    final allWorkouts = await _workoutRepository.getAllWorkouts();

    final todayDistanceMeters = _sumDistance(todaysWorkouts);
    final todayCalories = _sumCalories(todaysWorkouts);
    final todayActiveMinutes = _sumActiveMinutes(todaysWorkouts);
    final todaySteps = _estimateSteps(todayDistanceMeters);
    final dailyDistanceGoalKm = preferences.weeklyDistanceGoalKm / 7;

    return HomeDashboardData(
      userName: profile?.name ?? 'Athlete',
      gender: profile?.gender ?? 'male',
      stats: DailyStats(
        steps: todaySteps,
        stepsGoal: preferences.dailyStepGoal,
        calories: todayCalories,
        caloriesGoal: _defaultCaloriesGoal,
        distanceKm: todayDistanceMeters / 1000,
        distanceGoalKm: dailyDistanceGoalKm,
        activeMinutes: todayActiveMinutes,
        activeMinutesGoal: _defaultActiveMinutesGoal,
        workoutCount: todaysWorkouts.length,
      ),
      streakDays: StreakCalculator.calculate(
        allWorkouts.map((workout) => workout.startTime),
      ),
      weeklyActivity: _buildWeeklyActivity(weeklyWorkouts),
      hourlyActivity: _buildHourlyActivity(todaysWorkouts),
      recentWorkout: allWorkouts.isEmpty ? null : allWorkouts.first,
    );
  }

  HourlyActivityData _buildHourlyActivity(List<Workout> todaysWorkouts) {
    final steps = List<double>.filled(24, 0);
    final distanceKm = List<double>.filled(24, 0);
    final calories = List<double>.filled(24, 0);
    final activeMinutes = List<double>.filled(24, 0);

    for (final workout in todaysWorkouts) {
      _distributeWorkout(
        workout: workout,
        onSegment: (hour, fraction) {
          steps[hour] += _estimateSteps(workout.distanceInMeters) * fraction;
          distanceKm[hour] += (workout.distanceInMeters / 1000) * fraction;
          calories[hour] += workout.calories * fraction;
          activeMinutes[hour] +=
              (workout.durationInSeconds / 60) * fraction;
        },
      );
    }

    return HourlyActivityData(
      stepsByHour: steps,
      distanceKmByHour: distanceKm,
      caloriesByHour: calories,
      activeMinutesByHour: activeMinutes,
    );
  }

  void _distributeWorkout({
    required Workout workout,
    required void Function(int hour, double fraction) onSegment,
  }) {
    final totalSeconds = workout.durationInSeconds;
    if (totalSeconds <= 0) {
      onSegment(workout.startTime.hour, 1);
      return;
    }

    var cursor = workout.startTime;
    final end = workout.endTime;

    while (cursor.isBefore(end)) {
      final hour = cursor.hour;
      final hourEnd = DateTime(
        cursor.year,
        cursor.month,
        cursor.day,
        cursor.hour,
      ).add(const Duration(hours: 1));
      final segmentEnd = hourEnd.isBefore(end) ? hourEnd : end;
      final segmentSeconds = segmentEnd.difference(cursor).inSeconds;

      if (segmentSeconds > 0) {
        onSegment(hour, segmentSeconds / totalSeconds);
      }

      cursor = segmentEnd;
    }
  }

  List<WeeklyActivityDay> _buildWeeklyActivity(List<Workout> weeklyWorkouts) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));

    final distanceByDay = List<double>.filled(7, 0);
    for (final workout in weeklyWorkouts) {
      final dayIndex = workout.startTime.difference(weekStart).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        distanceByDay[dayIndex] += workout.distanceInMeters;
      }
    }

    final maxDistance = distanceByDay.reduce((a, b) => a > b ? a : b);
    final normalizationBase = maxDistance > 0 ? maxDistance : 1.0;

    return List.generate(labels.length, (index) {
      return WeeklyActivityDay(
        label: labels[index],
        value: distanceByDay[index] / normalizationBase,
      );
    });
  }

  double _sumDistance(List<Workout> workouts) {
    return workouts.fold<double>(
      0,
      (total, workout) => total + workout.distanceInMeters,
    );
  }

  int _sumCalories(List<Workout> workouts) {
    return workouts.fold<int>(
      0,
      (total, workout) => total + workout.calories,
    );
  }

  int _sumActiveMinutes(List<Workout> workouts) {
    return workouts.fold<int>(
      0,
      (total, workout) => total + (workout.durationInSeconds ~/ 60),
    );
  }

  int _estimateSteps(double distanceMeters) {
    return ((distanceMeters / 1000) * _stepsPerKm).round();
  }
}
