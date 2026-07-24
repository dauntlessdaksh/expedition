import 'package:expedition/core/gps/calculators/calorie_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalorieCalculator', () {
    late CalorieCalculator calculator;

    setUp(() {
      calculator = CalorieCalculator()
        ..configure(activityType: 'run', weightKg: 70);
    });

    test('does not increase calories when stationary', () {
      calculator.applyMovingSegment(
        deltaSeconds: 60,
        currentSpeedMps: 0,
        isMoving: false,
        gpsMovementAccepted: true,
      );

      expect(calculator.activeCaloriesRounded, 0);
    });

    test('does not increase calories without accepted GPS movement', () {
      calculator.applyMovingSegment(
        deltaSeconds: 60,
        currentSpeedMps: 3,
        isMoving: true,
        gpsMovementAccepted: false,
      );

      expect(calculator.activeCaloriesRounded, 0);
    });

    test('increases calories only during confirmed movement', () {
      calculator.applyMovingSegment(
        deltaSeconds: 60,
        currentSpeedMps: 3,
        isMoving: true,
        gpsMovementAccepted: true,
      );

      expect(calculator.activeCaloriesRounded, greaterThan(0));
    });

    test('uses higher MET for faster running pace', () {
      final slow = CalorieCalculator()
        ..configure(activityType: 'run', weightKg: 70);
      final fast = CalorieCalculator()
        ..configure(activityType: 'run', weightKg: 70);

      slow.applyMovingSegment(
        deltaSeconds: 600,
        currentSpeedMps: 2,
        isMoving: true,
        gpsMovementAccepted: true,
      );
      fast.applyMovingSegment(
        deltaSeconds: 600,
        currentSpeedMps: 4,
        isMoving: true,
        gpsMovementAccepted: true,
      );

      expect(fast.activeCaloriesRounded, greaterThan(slow.activeCaloriesRounded));
    });

    test('metForActivity returns walking MET tiers by speed', () {
      expect(CalorieCalculator.metForActivity('walk', 0.8), 3.5);
      expect(CalorieCalculator.metForActivity('walk', 1.2), 4.0);
      expect(CalorieCalculator.metForActivity('walk', 1.7), 4.5);
    });

    test('metForActivity returns hiking MET tiers by speed', () {
      expect(CalorieCalculator.metForActivity('hike', 0.6), 6.0);
      expect(CalorieCalculator.metForActivity('hike', 1.0), 7.0);
      expect(CalorieCalculator.metForActivity('hike', 1.6), 8.0);
    });
  });
}
