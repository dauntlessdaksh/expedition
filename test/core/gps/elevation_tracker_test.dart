import 'package:expedition/core/gps/trackers/elevation_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ElevationTracker', () {
    late ElevationTracker tracker;

    setUp(() {
      tracker = ElevationTracker(
        noiseThresholdMeters: 3,
        smoothingFactor: 0.3,
      );
    });

    test('tracks current altitude after smoothing', () {
      tracker.process(100);
      tracker.process(101);

      expect(tracker.currentAltitudeMeters, isNotNull);
      expect(tracker.currentAltitudeMeters!, closeTo(100.3, 0.5));
    });

    test('ignores elevation changes below noise threshold', () {
      tracker.process(100);
      tracker.process(101);
      tracker.process(102);

      expect(tracker.elevationGainMeters, 0);
      expect(tracker.elevationLossMeters, 0);
    });

    test('counts elevation gain above noise threshold', () {
      tracker.process(100);
      tracker.process(104);
      tracker.process(108);

      expect(tracker.elevationGainMeters, greaterThan(0));
      expect(tracker.highestElevationMeters, greaterThan(100));
    });

    test('counts elevation loss above noise threshold', () {
      tracker.process(200);
      tracker.process(196);
      tracker.process(192);

      expect(tracker.elevationLossMeters, greaterThan(0));
      expect(tracker.lowestElevationMeters, lessThan(200));
    });

    test('resets all values', () {
      tracker.process(150);
      tracker.process(160);
      tracker.reset();

      expect(tracker.currentAltitudeMeters, isNull);
      expect(tracker.elevationGainMeters, 0);
      expect(tracker.elevationLossMeters, 0);
      expect(tracker.highestElevationMeters, isNull);
      expect(tracker.lowestElevationMeters, isNull);
    });
  });
}
