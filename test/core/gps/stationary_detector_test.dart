import 'package:expedition/core/gps/detectors/stationary_detector.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('StationaryDetector', () {
    late StationaryDetector detector;

    setUp(() {
      detector = StationaryDetector();
    });

    test('enters stationary state after consecutive low movement samples', () {
      for (var i = 0; i < 3; i++) {
        detector.update(
          segmentMeters: 2,
          config: GpsTestFixtures.config,
        );
      }

      expect(detector.isMoving, isFalse);
    });

    test('requires consecutive high movement samples before moving', () {
      detector.update(
        segmentMeters: 8,
        config: GpsTestFixtures.config,
      );

      expect(detector.isMoving, isFalse);

      detector.update(
        segmentMeters: 8,
        config: GpsTestFixtures.config,
      );

      expect(detector.isMoving, isTrue);
    });

    test('returns to stationary after sustained low movement', () {
      detector
        ..update(segmentMeters: 8, config: GpsTestFixtures.config)
        ..update(segmentMeters: 8, config: GpsTestFixtures.config);

      expect(detector.isMoving, isTrue);

      for (var i = 0; i < 3; i++) {
        detector.update(
          segmentMeters: 2,
          config: GpsTestFixtures.config,
        );
      }

      expect(detector.isMoving, isFalse);
    });
  });
}
