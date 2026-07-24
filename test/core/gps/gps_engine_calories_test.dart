import 'package:expedition/core/gps/gps_engine.dart';
import 'package:expedition/core/gps/gps_tracking_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('GpsEngine calories', () {
    late GpsEngine engine;

    setUp(() {
      engine = GpsEngine(config: GpsTestFixtures.config);
    });

    test('does not increase active calories while waiting for movement', () {
      GpsTestFixtures.acquireGpsLock(engine);

      for (var second = 3; second <= 10; second++) {
        engine.process(
          GpsTestFixtures.raw(
            lat: GpsTestFixtures.seed.latitude,
            lng: GpsTestFixtures.seed.longitude,
            timestamp: DateTime(2026, 1, 1, 10, 0, second),
          ),
        );
      }

      expect(engine.trackingState, GpsTrackingState.waitingForMovement);
      expect(engine.lastLocation?.activeCalories, 0);
    });

    test('increases active calories after movement is confirmed', () {
      GpsTestFixtures.acquireGpsLock(
        engine,
        start: DateTime(2026, 1, 1, 10),
      );

      final last = GpsTestFixtures.confirmMovement(
        engine,
        start: DateTime(2026, 1, 1, 10, 0, 3),
      );

      expect(engine.trackingState, GpsTrackingState.tracking);
      expect(last.activeCalories, greaterThan(0));
    });
  });
}
