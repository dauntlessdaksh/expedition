import 'package:expedition/core/gps/filters/accuracy_filter.dart';
import 'package:expedition/core/gps/gps_engine_config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('AccuracyFilter', () {
    const filter = AccuracyFilter();
    const config = GpsEngineConfig(
      minimumAccuracy: 15,
      minimumMovementMeters: 5,
      minimumUpdateInterval: Duration(seconds: 1),
      speedSmoothingWindow: 5,
      stationarySamplesRequired: 3,
      minimumMovingSpeedMps: 0.8,
      maximumSpeedMps: 25 / 3.6,
    );

    test('accepts fixes within accuracy threshold', () {
      final position = GpsTestFixtures.raw(
        lat: 28.6139,
        lng: 77.2090,
        timestamp: DateTime(2026, 1, 1),
        accuracy: 12,
      );

      expect(filter.passes(position, config), isTrue);
    });

    test('rejects fixes worse than accuracy threshold', () {
      final position = GpsTestFixtures.raw(
        lat: 28.6139,
        lng: 77.2090,
        timestamp: DateTime(2026, 1, 1),
        accuracy: 20,
      );

      expect(filter.passes(position, config), isFalse);
    });
  });
}
