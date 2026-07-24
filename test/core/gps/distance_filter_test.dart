import 'package:expedition/core/gps/filters/distance_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('DistanceFilter', () {
    const filter = DistanceFilter();

    test('computes segment distance between two coordinates', () {
      const from = LatLng(28.6139, 77.2090);
      const to = LatLng(28.61395, 77.2090);

      final segment = filter.segmentMeters(from: from, to: to);

      expect(segment, greaterThan(4));
      expect(segment, lessThan(7));
    });

    test('rejects segments below the movement threshold', () {
      expect(
        filter.passesSegment(3, GpsTestFixtures.config),
        isFalse,
      );
    });

    test('accepts segments at or above the movement threshold', () {
      expect(
        filter.passesSegment(5, GpsTestFixtures.config),
        isTrue,
      );
    });
  });
}
