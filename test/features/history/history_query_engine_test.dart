import 'package:expedition/features/history/domain/models/history_filter.dart';
import 'package:expedition/features/history/domain/models/history_sort.dart';
import 'package:expedition/features/history/domain/models/workout.dart';
import 'package:expedition/features/history/domain/services/history_query_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('HistoryQueryEngine', () {
    final workouts = [
      Workout(
        id: 1,
        activityType: 'outdoor_run',
        startTime: DateTime(2026, 7, 22),
        endTime: DateTime(2026, 7, 22, 1),
        durationInSeconds: 3600,
        distanceInMeters: 10000,
        averageSpeed: 2.7,
        maxSpeed: 4.2,
        calories: 500,
        polyline: const [LatLng(0, 0)],
        createdAt: DateTime(2026, 7, 22),
      ),
      Workout(
        id: 2,
        activityType: 'outdoor_walk',
        startTime: DateTime(2026, 7, 10),
        endTime: DateTime(2026, 7, 10, 1),
        durationInSeconds: 1800,
        distanceInMeters: 3000,
        averageSpeed: 1.6,
        maxSpeed: 2.1,
        calories: 180,
        polyline: const [LatLng(1, 1)],
        createdAt: DateTime(2026, 7, 10),
      ),
    ];

    test('filters by search query', () {
      final result = HistoryQueryEngine.apply(
        workouts: workouts,
        searchQuery: 'run',
        filter: HistoryFilter.allTime,
        sort: HistorySort.newestFirst,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 1);
    });

    test('sorts by longest distance', () {
      final result = HistoryQueryEngine.apply(
        workouts: workouts,
        searchQuery: '',
        filter: HistoryFilter.allTime,
        sort: HistorySort.longestDistance,
      );

      expect(result.first.distanceInMeters, 10000);
    });
  });
}
