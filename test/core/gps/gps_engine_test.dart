import 'package:expedition/core/gps/filtered_location.dart';
import 'package:expedition/core/gps/gps_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('GpsEngine', () {
    late GpsEngine engine;

    setUp(() {
      engine = GpsEngine(config: GpsTestFixtures.config);
    });

    void beginAtDefaultSeed() {
      engine.beginSession(
        seed: const LatLng(28.6139, 77.2090),
        accuracyMeters: 8,
        timestamp: DateTime(2026, 1, 1, 10),
      );
    }

    test('rejects poor accuracy fixes', () {
      beginAtDefaultSeed();

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: 28.6139,
          lng: 77.2090,
          timestamp: DateTime(2026, 1, 1, 10, 0, 2),
          accuracy: 20,
        ),
      );

      expect(result.rejectReason, GpsRejectReason.accuracy);
      expect(result.wasAccepted, isFalse);
      expect(engine.lastLocation?.totalDistance, 0);
    });

    test('ignores stationary GPS drift under movement threshold', () {
      beginAtDefaultSeed();

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: 28.61391,
          lng: 77.20901,
          timestamp: DateTime(2026, 1, 1, 10, 0, 2),
        ),
      );

      expect(result.rejectReason, GpsRejectReason.stationary);
      expect(engine.lastLocation?.totalDistance, 0);
    });

    test('accepts movement and uses moving time for average speed', () {
      beginAtDefaultSeed();

      engine.process(
        GpsTestFixtures.raw(
          lat: 28.61395,
          lng: 77.2090,
          timestamp: DateTime(2026, 1, 1, 10, 0, 2),
        ),
      );

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: 28.61400,
          lng: 77.2090,
          timestamp: DateTime(2026, 1, 1, 10, 0, 4),
        ),
      );

      expect(result.wasAccepted, isTrue);
      expect(result.location!.totalDistance, greaterThan(4));
      expect(result.location!.movingTime.inSeconds, greaterThan(0));
      expect(
        result.location!.averageSpeed,
        closeTo(
          result.location!.totalDistance /
              result.location!.movingTime.inSeconds,
          0.05,
        ),
      );
      expect(result.location!.currentSpeed, isNot(25));
    });

    test('ignores updates received less than one second apart', () {
      beginAtDefaultSeed();

      engine.process(
        GpsTestFixtures.raw(
          lat: 28.61395,
          lng: 77.2090,
          timestamp: DateTime(2026, 1, 1, 10, 0, 2),
        ),
      );

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: 28.61400,
          lng: 77.2090,
          timestamp: DateTime(2026, 1, 1, 10, 0, 2, 500),
        ),
      );

      expect(result.rejectReason, GpsRejectReason.time);
    });

    test('rejects impossible GPS jumps', () {
      beginAtDefaultSeed();

      final result = engine.process(
        GpsTestFixtures.raw(
          lat: 28.62,
          lng: 77.2090,
          timestamp: DateTime(2026, 1, 1, 10, 0, 2),
        ),
      );

      expect(result.rejectReason, GpsRejectReason.impossibleSpeed);
    });

    test('pauses and resumes elapsed time', () {
      engine.beginSession(
        seed: const LatLng(28.6139, 77.2090),
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
