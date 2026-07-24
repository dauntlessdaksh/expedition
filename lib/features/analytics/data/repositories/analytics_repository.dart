import '../../../history/data/repositories/workout_repository.dart';
import '../../../history/domain/models/workout.dart';
import '../../../shared/utils/streak_calculator.dart';
import '../../../shared/utils/workout_display_formatters.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/domain/models/profile_models.dart';
import '../../domain/models/analytics_chart_models.dart';
import '../../domain/models/analytics_data.dart';
import '../../domain/models/analytics_records.dart';
import '../../domain/models/analytics_summary.dart';
import '../../domain/models/monthly_trend_range.dart';
import '../../domain/services/activity_category_mapper.dart';

/// Builds analytics metrics from persisted workouts.
class AnalyticsRepository {
  const AnalyticsRepository({
    required WorkoutRepository workoutRepository,
    required ProfileRepository profileRepository,
  })  : _workoutRepository = workoutRepository,
        _profileRepository = profileRepository;

  final WorkoutRepository _workoutRepository;
  final ProfileRepository _profileRepository;

  static const _weeklyActiveMinutesGoal = 420;

  static const _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<AnalyticsData> getAnalyticsData() async {
    final allWorkouts = await _workoutRepository.getAllWorkouts();
    final weeklyWorkouts = await _workoutRepository.getWeeklyWorkouts();
    final preferences = await _profileRepository.getPreferences();
    final workoutDates = allWorkouts.map((workout) => workout.startTime);

    return AnalyticsData(
      summary: _buildSummary(allWorkouts),
      weeklyActivity: _buildWeeklyActivity(weeklyWorkouts),
      monthlyTrends: _buildMonthlyTrends(allWorkouts),
      activityDistribution: _buildActivityDistribution(allWorkouts),
      personalRecords: _buildPersonalRecords(allWorkouts),
      streakStats: StreakStats(
        currentStreak: StreakCalculator.calculate(workoutDates),
        longestStreak: StreakCalculator.longestStreak(workoutDates),
        totalActiveDays: StreakCalculator.totalActiveDays(workoutDates),
      ),
      goalProgress: _buildGoalProgress(
        allWorkouts,
        weeklyWorkouts,
        preferences,
      ),
      insights: _buildInsights(allWorkouts, weeklyWorkouts, preferences),
    );
  }

  AnalyticsSummary _buildSummary(List<Workout> workouts) {
    return AnalyticsSummary(
      totalDistanceMeters: workouts.fold<double>(
        0,
        (total, workout) => total + workout.distanceInMeters,
      ),
      totalWorkouts: workouts.length,
      totalActiveSeconds: workouts.fold<int>(
        0,
        (total, workout) => total + workout.durationInSeconds,
      ),
      totalCalories: workouts.fold<int>(
        0,
        (total, workout) => total + workout.calories,
      ),
    );
  }

  List<AnalyticsWeeklyDay> _buildWeeklyActivity(List<Workout> weeklyWorkouts) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));

    final distanceByDay = List<double>.filled(7, 0);
    for (final workout in weeklyWorkouts) {
      final dayIndex = workout.startTime.difference(weekStart).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        distanceByDay[dayIndex] += workout.distanceInMeters / 1000;
      }
    }

    return List.generate(_weekdayLabels.length, (index) {
      return AnalyticsWeeklyDay(
        label: _weekdayLabels[index],
        distanceKm: distanceByDay[index],
      );
    });
  }

  Map<MonthlyTrendRange, List<AnalyticsTrendPoint>> _buildMonthlyTrends(
    List<Workout> workouts,
  ) {
    return {
      for (final range in MonthlyTrendRange.values)
        range: _buildTrendPoints(workouts, range.days),
    };
  }

  List<AnalyticsTrendPoint> _buildTrendPoints(
    List<Workout> workouts,
    int days,
  ) {
    final end = _dateOnly(DateTime.now());
    final start = end.subtract(Duration(days: days - 1));

    return List.generate(days, (index) {
      final day = start.add(Duration(days: index));
      final nextDay = day.add(const Duration(days: 1));
      final distanceMeters = workouts
          .where(
            (workout) =>
                !workout.startTime.isBefore(day) &&
                workout.startTime.isBefore(nextDay),
          )
          .fold<double>(
            0,
            (total, workout) => total + workout.distanceInMeters,
          );

      return AnalyticsTrendPoint(
        date: day,
        distanceKm: distanceMeters / 1000,
      );
    });
  }

  ActivityDistribution _buildActivityDistribution(List<Workout> workouts) {
    if (workouts.isEmpty) {
      return const ActivityDistribution(
        walkingPercent: 0,
        runningPercent: 0,
        cyclingPercent: 0,
        otherPercent: 0,
      );
    }

    final counts = <ActivityCategory, int>{
      ActivityCategory.walking: 0,
      ActivityCategory.running: 0,
      ActivityCategory.cycling: 0,
      ActivityCategory.other: 0,
    };

    for (final workout in workouts) {
      final category = ActivityCategoryMapper.categorize(workout.activityType);
      counts[category] = counts[category]! + 1;
    }

    double percent(int count) => (count / workouts.length) * 100;

    return ActivityDistribution(
      walkingPercent: percent(counts[ActivityCategory.walking]!),
      runningPercent: percent(counts[ActivityCategory.running]!),
      cyclingPercent: percent(counts[ActivityCategory.cycling]!),
      otherPercent: percent(counts[ActivityCategory.other]!),
    );
  }

  PersonalRecords _buildPersonalRecords(List<Workout> workouts) {
    if (workouts.isEmpty) {
      return const PersonalRecords(
        longestWorkout: PersonalRecord(label: 'Longest Workout', value: '--'),
        longestDistance: PersonalRecord(label: 'Longest Distance', value: '--'),
        fastestAverageSpeed: PersonalRecord(
          label: 'Fastest Average Speed',
          value: '--',
        ),
        highestCalories: PersonalRecord(
          label: 'Highest Calories',
          value: '--',
        ),
        longestDuration: PersonalRecord(
          label: 'Longest Duration',
          value: '--',
        ),
      );
    }

    final longestDistanceWorkout = workouts.reduce(
      (best, workout) =>
          workout.distanceInMeters > best.distanceInMeters ? workout : best,
    );
    final longestDurationWorkout = workouts.reduce(
      (best, workout) =>
          workout.durationInSeconds > best.durationInSeconds ? workout : best,
    );
    final fastestWorkout = workouts.reduce(
      (best, workout) =>
          workout.averageSpeed > best.averageSpeed ? workout : best,
    );
    final highestCaloriesWorkout = workouts.reduce(
      (best, workout) => workout.calories > best.calories ? workout : best,
    );

    return PersonalRecords(
      longestWorkout: PersonalRecord(
        label: 'Longest Workout',
        value: WorkoutDisplayFormatters.distanceMeters(
          longestDistanceWorkout.distanceInMeters,
        ),
        subtitle: WorkoutDisplayFormatters.workoutDateShort(
          longestDistanceWorkout.startTime,
        ),
      ),
      longestDistance: PersonalRecord(
        label: 'Longest Distance',
        value: WorkoutDisplayFormatters.distanceMeters(
          longestDistanceWorkout.distanceInMeters,
        ),
        subtitle: WorkoutDisplayFormatters.activityType(
          longestDistanceWorkout.activityType,
        ),
      ),
      fastestAverageSpeed: PersonalRecord(
        label: 'Fastest Average Speed',
        value: WorkoutDisplayFormatters.speedMps(fastestWorkout.averageSpeed),
        subtitle: WorkoutDisplayFormatters.workoutDateShort(
          fastestWorkout.startTime,
        ),
      ),
      highestCalories: PersonalRecord(
        label: 'Highest Calories',
        value: '${highestCaloriesWorkout.calories} kcal',
        subtitle: WorkoutDisplayFormatters.workoutDateShort(
          highestCaloriesWorkout.startTime,
        ),
      ),
      longestDuration: PersonalRecord(
        label: 'Longest Duration',
        value: WorkoutDisplayFormatters.durationSeconds(
          longestDurationWorkout.durationInSeconds,
        ),
        subtitle: WorkoutDisplayFormatters.workoutDateShort(
          longestDurationWorkout.startTime,
        ),
      ),
    );
  }

  List<GoalProgressItem> _buildGoalProgress(
    List<Workout> allWorkouts,
    List<Workout> weeklyWorkouts,
    UserPreferences preferences,
  ) {
    final weeklyDistanceKm = weeklyWorkouts.fold<double>(
          0,
          (total, workout) => total + workout.distanceInMeters,
        ) /
        1000;
    final weeklyActiveMinutes = weeklyWorkouts.fold<int>(
      0,
      (total, workout) => total + (workout.durationInSeconds ~/ 60),
    );

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);
    final monthlyWorkouts = allWorkouts
        .where(
          (workout) =>
              !workout.startTime.isBefore(monthStart) &&
              workout.startTime.isBefore(monthEnd),
        )
        .length;

    final monthlyWorkoutGoal = preferences.monthlyWorkoutGoal;

    return [
      GoalProgressItem(
        label: 'Weekly Distance',
        progress: weeklyDistanceKm / preferences.weeklyDistanceGoalKm,
        valueLabel: '${weeklyDistanceKm.toStringAsFixed(1)} km',
        goalLabel: '${preferences.weeklyDistanceGoalKm.toStringAsFixed(0)} km',
      ),
      GoalProgressItem(
        label: 'Monthly Workouts',
        progress: monthlyWorkouts / monthlyWorkoutGoal,
        valueLabel: '$monthlyWorkouts workouts',
        goalLabel: '$monthlyWorkoutGoal workouts',
      ),
      GoalProgressItem(
        label: 'Weekly Active Minutes',
        progress: weeklyActiveMinutes / _weeklyActiveMinutesGoal,
        valueLabel: '$weeklyActiveMinutes min',
        goalLabel: '$_weeklyActiveMinutesGoal min',
      ),
    ];
  }

  List<String> _buildInsights(
    List<Workout> allWorkouts,
    List<Workout> weeklyWorkouts,
    UserPreferences preferences,
  ) {
    if (allWorkouts.isEmpty) {
      return const [];
    }

    final insights = <String>[];

    final dayCounts = List<int>.filled(7, 0);
    for (final workout in allWorkouts) {
      dayCounts[workout.startTime.weekday - 1]++;
    }
    final favoriteDayIndex = _indexOfMax(dayCounts);
    insights.add(
      'You usually exercise on ${_weekdayNames[favoriteDayIndex]}s.',
    );

    final averageMinutes = allWorkouts.fold<int>(
          0,
          (total, workout) => total + workout.durationInSeconds,
        ) ~/
        allWorkouts.length ~/
        60;
    insights.add('Average workout duration is $averageMinutes minutes.');

    final longestDistance = allWorkouts.fold<double>(
      0,
      (best, workout) =>
          workout.distanceInMeters > best ? workout.distanceInMeters : best,
    );
    insights.add(
      'Your longest activity was ${(longestDistance / 1000).toStringAsFixed(1)} km.',
    );

    final weeklyDistanceKm = weeklyWorkouts.fold<double>(
          0,
          (total, workout) => total + workout.distanceInMeters,
        ) /
        1000;
    final weeklyProgress =
        ((weeklyDistanceKm / preferences.weeklyDistanceGoalKm) * 100).round();
    insights.add("You're $weeklyProgress% toward this week's goal.");

    return insights;
  }

  int _indexOfMax(List<int> values) {
    var maxIndex = 0;
    for (var index = 1; index < values.length; index++) {
      if (values[index] > values[maxIndex]) {
        maxIndex = index;
      }
    }
    return maxIndex;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
