import 'package:expedition/core/gps/calculators/speed_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('SpeedCalculator', () {
    late SpeedCalculator calculator;

    setUp(() {
      calculator = SpeedCalculator();
    });

    test('returns zero speed when not moving', () {
      final speed = calculator.recordSpeed(
        segmentMeters: 10,
        deltaSeconds: 2,
        config: GpsTestFixtures.config,
        isMoving: false,
      );

      expect(speed, 0);
    });

    test('rejects impossible speed spikes', () {
      final speed = calculator.recordSpeed(
        segmentMeters: 100,
        deltaSeconds: 1,
        config: GpsTestFixtures.config,
        isMoving: true,
      );

      expect(speed, isNull);
    });

    test('smooths speed using a rolling window', () {
      calculator.recordSpeed(
        segmentMeters: 4,
        deltaSeconds: 1,
        config: GpsTestFixtures.config,
        isMoving: true,
      );
      calculator.recordSpeed(
        segmentMeters: 6,
        deltaSeconds: 1,
        config: GpsTestFixtures.config,
        isMoving: true,
      );

      expect(calculator.smoothedSpeed(), closeTo(5, 0.01));
    });

    test('tracks the maximum observed speed', () {
      calculator.recordSpeed(
        segmentMeters: 8,
        deltaSeconds: 1,
        config: GpsTestFixtures.config,
        isMoving: true,
      );

      expect(calculator.maxSpeedMps, closeTo(8, 0.01));
    });
  });
}
