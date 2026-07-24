import 'package:expedition/core/gps/calculators/distance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('DistanceCalculator', () {
    late DistanceCalculator calculator;

    setUp(() {
      calculator = DistanceCalculator();
    });

    test('does not accumulate distance while stationary', () {
      calculator.applyAcceptedSegment(
        segmentMeters: 10,
        deltaSeconds: 2,
        smoothedSpeedMps: 3,
        isMoving: false,
        config: GpsTestFixtures.config,
      );

      expect(calculator.totalDistanceMeters, 0);
      expect(calculator.movingTime, Duration.zero);
    });

    test('accumulates distance and moving time while moving', () {
      calculator.applyAcceptedSegment(
        segmentMeters: 10,
        deltaSeconds: 2,
        smoothedSpeedMps: 3,
        isMoving: true,
        config: GpsTestFixtures.config,
      );

      expect(calculator.totalDistanceMeters, 10);
      expect(calculator.movingTime.inSeconds, 2);
    });

    test('computes average speed using moving time only', () {
      calculator.applyAcceptedSegment(
        segmentMeters: 10,
        deltaSeconds: 2,
        smoothedSpeedMps: 3,
        isMoving: true,
        config: GpsTestFixtures.config,
      );

      expect(calculator.averageSpeedMps(), closeTo(5, 0.01));
    });

    test('ignores segments below minimum moving speed', () {
      calculator.applyAcceptedSegment(
        segmentMeters: 10,
        deltaSeconds: 20,
        smoothedSpeedMps: 0.5,
        isMoving: true,
        config: GpsTestFixtures.config,
      );

      expect(calculator.totalDistanceMeters, 0);
      expect(calculator.movingTime, Duration.zero);
    });
  });
}
