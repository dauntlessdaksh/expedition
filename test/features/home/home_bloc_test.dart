import 'package:bloc_test/bloc_test.dart';
import 'package:expedition/features/home/domain/models/home_dashboard_data.dart';
import 'package:expedition/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';

void main() {
  late MockHomeRepository repository;

  setUp(() {
    repository = MockHomeRepository();
  });

  blocTest<HomeBloc, HomeState>(
    'loads dashboard data',
    build: () => HomeBloc(repository: repository),
    setUp: () {
      when(() => repository.getDashboardData()).thenAnswer(
        (_) async => HomeDashboardData(
          userName: 'Alex',
          gender: 'male',
          streakDays: 3,
          stats: const DailyStats(
            steps: 6000,
            stepsGoal: 10000,
            calories: 400,
            caloriesGoal: 600,
            distanceKm: 4.2,
            distanceGoalKm: 8,
            activeMinutes: 35,
            activeMinutesGoal: 60,
            workoutCount: 1,
          ),
          weeklyActivity: const [],
          hourlyActivity: HourlyActivityData(
            stepsByHour: List.filled(24, 0),
            distanceKmByHour: List.filled(24, 0),
            caloriesByHour: List.filled(24, 0),
            activeMinutesByHour: List.filled(24, 0),
          ),
        ),
      );
    },
    act: (bloc) => bloc.add(const LoadDashboard()),
    expect: () => [
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>()
          .having((state) => state.status, 'status', HomeStatus.loaded)
          .having((state) => state.data?.userName, 'userName', 'Alex'),
    ],
  );
}
