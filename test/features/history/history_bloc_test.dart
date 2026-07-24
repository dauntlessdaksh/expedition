import 'package:bloc_test/bloc_test.dart';
import 'package:expedition/features/history/domain/models/workout.dart';
import 'package:expedition/features/history/presentation/bloc/history_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';

void main() {
  late MockHistoryRepository repository;

  setUp(() {
    repository = MockHistoryRepository();
  });

  blocTest<HistoryBloc, HistoryState>(
    'emits loaded state when workouts exist',
    build: () => HistoryBloc(repository: repository),
    setUp: () {
      when(() => repository.getAllWorkouts()).thenAnswer(
        (_) async => [
          Workout(
            id: 1,
            activityType: 'outdoor_run',
            startTime: DateTime(2026, 7, 22),
            endTime: DateTime(2026, 7, 22, 1),
            durationInSeconds: 1200,
            distanceInMeters: 5000,
            averageSpeed: 2.5,
            maxSpeed: 3.5,
            calories: 300,
            polyline: const [LatLng(0, 0)],
            createdAt: DateTime(2026, 7, 22),
          ),
        ],
      );
    },
    act: (bloc) => bloc.add(const LoadHistory()),
    expect: () => [
      isA<HistoryState>().having(
        (state) => state.status,
        'status',
        HistoryStatus.loading,
      ),
      isA<HistoryState>()
          .having((state) => state.status, 'status', HistoryStatus.loaded)
          .having((state) => state.visibleWorkouts.length, 'count', 1),
    ],
  );

  blocTest<HistoryBloc, HistoryState>(
    'emits empty state when no workouts exist',
    build: () => HistoryBloc(repository: repository),
    setUp: () {
      when(() => repository.getAllWorkouts()).thenAnswer((_) async => []);
    },
    act: (bloc) => bloc.add(const LoadHistory()),
    expect: () => [
      isA<HistoryState>().having(
        (state) => state.status,
        'status',
        HistoryStatus.loading,
      ),
      isA<HistoryState>().having(
        (state) => state.status,
        'status',
        HistoryStatus.empty,
      ),
    ],
  );
}
