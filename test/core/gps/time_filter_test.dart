import 'package:expedition/core/gps/filters/time_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/gps_test_fixtures.dart';

void main() {
  group('TimeFilter', () {
    late TimeFilter filter;

    setUp(() {
      filter = TimeFilter();
    });

    test('accepts the first processed timestamp', () {
      final timestamp = DateTime(2026, 1, 1, 10);

      expect(filter.passes(timestamp, GpsTestFixtures.config), isTrue);
    });

    test('rejects updates received faster than the minimum interval', () {
      final first = DateTime(2026, 1, 1, 10);
      final tooSoon = first.add(const Duration(milliseconds: 500));

      filter
        ..passes(first, GpsTestFixtures.config)
        ..markProcessed(first);

      expect(filter.passes(tooSoon, GpsTestFixtures.config), isFalse);
    });

    test('accepts updates spaced by the minimum interval', () {
      final first = DateTime(2026, 1, 1, 10);
      final next = first.add(const Duration(seconds: 1));

      filter
        ..passes(first, GpsTestFixtures.config)
        ..markProcessed(first);

      expect(filter.passes(next, GpsTestFixtures.config), isTrue);
    });
  });
}
