import 'package:bloc_test/bloc_test.dart';
import 'package:expedition/features/analytics/domain/models/analytics_chart_models.dart';
import 'package:expedition/features/analytics/domain/models/analytics_data.dart';
import 'package:expedition/features/analytics/domain/models/analytics_records.dart';
import 'package:expedition/features/analytics/domain/models/analytics_summary.dart';
import 'package:expedition/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';

AnalyticsData _emptyAnalyticsData() {
  const emptyRecord = PersonalRecord(label: '—', value: '—');
  return AnalyticsData(
    summary: const AnalyticsSummary(
      totalDistanceMeters: 0,
      totalWorkouts: 0,
      totalActiveSeconds: 0,
      totalCalories: 0,
    ),
    weeklyActivity: const [],
    monthlyTrends: const {},
    activityDistribution: const ActivityDistribution(
      walkingPercent: 0,
      runningPercent: 0,
      cyclingPercent: 0,
      otherPercent: 0,
    ),
    personalRecords: const PersonalRecords(
      longestWorkout: emptyRecord,
      longestDistance: emptyRecord,
      fastestAverageSpeed: emptyRecord,
      highestCalories: emptyRecord,
      longestDuration: emptyRecord,
    ),
    streakStats: const StreakStats(
      currentStreak: 0,
      longestStreak: 0,
      totalActiveDays: 0,
    ),
    goalProgress: const [],
    insights: const [],
  );
}

void main() {
  late MockAnalyticsRepository repository;

  setUp(() {
    repository = MockAnalyticsRepository();
  });

  blocTest<AnalyticsBloc, AnalyticsState>(
    'emits empty when analytics data has no workouts',
    build: () => AnalyticsBloc(repository: repository),
    setUp: () {
      when(() => repository.getAnalyticsData()).thenAnswer(
        (_) async => _emptyAnalyticsData(),
      );
    },
    act: (bloc) => bloc.add(const LoadAnalytics()),
    expect: () => [
      isA<AnalyticsState>().having(
        (state) => state.status,
        'status',
        AnalyticsStatus.loading,
      ),
      isA<AnalyticsState>().having(
        (state) => state.status,
        'status',
        AnalyticsStatus.empty,
      ),
    ],
  );
}
