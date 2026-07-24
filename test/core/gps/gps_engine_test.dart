import 'package:expedition/core/gps/filtered_location.dart';
import 'package:expedition/core/gps/gps_engine.dart';
import 'package:expedition/core/gps/gps_tracking_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('GpsEngine', () {
    late GpsEngine engine;

    setUp(() {
      engine = GpsEngine(config: GpsTestFixtures.config);
    });

    test('acquires GPS lock after three consecutive accurate fixes', () {
      final start = DateTime(2026, 1, 1, 10);

      engine.beginSession(
        seed: GpsTestFixtures.seed,
        accuracyMeters: 8,
        timestamp: start,
      );

      expect(engine.hasGpsLock, isFalse);
      expect(engine.trackingState, GpsTrackingState.waitingForGpsLock);

      engine.process(
        GpsTestFixtures.raw(
          lat: GpsTestFixtures.seed.latitude,
          lng: GpsTestFixtures.seed.longitude,
          timestamp: start.add(const Duration(seconds: 1)),
        ),
      );
      engine.process(
        GpsTestFixtures.raw(
          lat: GpsTestFixtures.seed.latitude,
          lng: GpsTestFixtures.seed.longitude,
          timestamp: start.add(const Duration(seconds: 2)),
        ),
      );

      expect(engine.hasGpsLock, isTrue);
      expect(engine.trackingState, GpsTrackingState.waitingForMovement);
    });

    test('preserves preview GPS lock when a session starts', () {
      for (var second = 0; second < 3; second++) {
        engine.processPreview(
          GpsTestFixtures.raw(
            lat: GpsTestFixtures.seed.latitude,
            lng: GpsTestFixtures.seed.longitude,
            timestamp: DateTime(2026, 1, 1, 9, 0, second),
          ),
        );
      }

      expect(engine.hasGpsLock, isTrue);

      engine.beginSession(
        seed: GpsTestFixtures.seed,
        accuracyMeters: 8,
        timestamp: DateTime(2026, 1, 1, 10),
      );

      expect(engine.hasGpsLock, isTrue);
      expect(engine.trackingState, GpsTrackingState.waitingForMovement);
    });

    test('does not accumulate distance while waiting for movement', () {
      GpsTestFixtures.acquireGpsLock(engine);

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: GpsTestFixtures.seed.latitude + 0.00005,
          lng: GpsTestFixtures.seed.longitude,
          timestamp: DateTime(2026, 1, 1, 10, 0, 3),
        ),
      );

      expect(engine.trackingState, GpsTrackingState.waitingForMovement);
      expect(result.location!.totalDistance, 0);
      expect(result.location!.currentSpeed, 0);
      expect(result.location!.polyline, isEmpty);
    });

    test('accepts poor accuracy fixes without accumulating distance', () {
      GpsTestFixtures.acquireGpsLock(engine);

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: GpsTestFixtures.seed.latitude,
          lng: GpsTestFixtures.seed.longitude,
          timestamp: DateTime(2026, 1, 1, 10, 0, 3),
          accuracy: 20,
        ),
      );

      expect(result.wasAccepted, isTrue);
      expect(result.location!.totalDistance, 0);
      expect(result.location!.currentSpeed, 0);
    });

    test('tracks distance only after movement is confirmed', () {
      GpsTestFixtures.acquireGpsLock(engine);
      final confirmed = GpsTestFixtures.confirmMovement(engine);

      expect(confirmed.totalDistance, greaterThan(10));
      expect(confirmed.movingTime.inSeconds, greaterThan(0));
      expect(confirmed.polyline.length, greaterThan(1));
      expect(
        confirmed.averageSpeed,
        closeTo(
          confirmed.totalDistance / confirmed.movingTime.inSeconds,
          0.05,
        ),
      );
    });

    test('ignores stationary GPS drift while tracking', () {
      GpsTestFixtures.acquireGpsLock(engine);
      GpsTestFixtures.confirmMovement(engine);

      final lastPosition = engine.lastLocation!.position;
      final before = engine.lastLocation!.totalDistance;

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: lastPosition.latitude + 0.0000005,
          lng: lastPosition.longitude + 0.0000005,
          timestamp: DateTime(2026, 1, 1, 10, 0, 8),
        ),
      );

      expect(engine.trackingState, GpsTrackingState.possibleStop);
      expect(result.location!.totalDistance, before);
      expect(result.location!.currentSpeed, 0);
    });

    test('enters stopped after four consecutive stationary updates', () {
      GpsTestFixtures.acquireGpsLock(engine);
      GpsTestFixtures.confirmMovement(engine);

      var timestamp = DateTime(2026, 1, 1, 10, 0, 8);
      for (var i = 0; i < 4; i++) {
        timestamp = timestamp.add(const Duration(seconds: 1));
        engine.process(
          GpsTestFixtures.raw(
            lat: GpsTestFixtures.seed.latitude + 0.00012 + (i * 0.0000002),
            lng: GpsTestFixtures.seed.longitude,
            timestamp: timestamp,
            accuracy: 8,
          ),
        );
      }

      expect(engine.trackingState, GpsTrackingState.stopped);
      expect(engine.lastLocation!.currentSpeed, 0);
    });

    test('does not add polyline points outside tracking state', () {
      GpsTestFixtures.acquireGpsLock(engine);

      expect(engine.lastLocation!.polyline, isEmpty);

      GpsTestFixtures.confirmMovement(engine);
      final trackingPoints = engine.lastLocation!.polyline.length;
      expect(trackingPoints, greaterThan(1));

      var timestamp = DateTime(2026, 1, 1, 10, 0, 8);
      for (var i = 0; i < 4; i++) {
        timestamp = timestamp.add(const Duration(seconds: 1));
        engine.process(
          GpsTestFixtures.raw(
            lat: GpsTestFixtures.seed.latitude + 0.00012 + (i * 0.0000002),
            lng: GpsTestFixtures.seed.longitude,
            timestamp: timestamp,
          ),
        );
      }

      expect(engine.trackingState, GpsTrackingState.stopped);
      expect(engine.lastLocation!.polyline.length, trackingPoints);
    });

    test('ignores updates received less than one second apart', () {
      GpsTestFixtures.acquireGpsLock(engine);

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: GpsTestFixtures.seed.latitude,
          lng: GpsTestFixtures.seed.longitude,
          timestamp: DateTime(2026, 1, 1, 10, 0, 2, 500),
        ),
      );

      expect(result.rejectReason, GpsRejectReason.time);
    });

    test('rejects impossible GPS jumps while tracking', () {
      GpsTestFixtures.acquireGpsLock(engine);
      GpsTestFixtures.confirmMovement(engine);

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: 28.62,
          lng: GpsTestFixtures.seed.longitude,
          timestamp: DateTime(2026, 1, 1, 10, 0, 10),
        ),
      );

      expect(result.rejectReason, GpsRejectReason.impossibleSpeed);
    });

    test('pauses and resumes elapsed time', () {
      engine.beginSession(
        seed: GpsTestFixtures.seed,
        accuracyMeters: 8,
      );

      engine.pauseSession();
      final pausedElapsed = engine.elapsedTime;

      engine.resumeSession();

      expect(
        engine.elapsedTime.inMilliseconds,
        greaterThanOrEqualTo(pausedElapsed.inMilliseconds),
      );
    });
  });
}
