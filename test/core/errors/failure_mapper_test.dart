import 'package:expedition/core/errors/app_failure.dart';
import 'package:expedition/core/errors/failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailureMapper', () {
    test('maps database errors', () {
      final failure = FailureMapper.from(Exception('SqliteException: disk I/O'));
      expect(failure.type, AppFailureType.database);
      expect(failure.canRetry, isTrue);
    });

    test('maps permanently denied permissions', () {
      final failure = FailureMapper.from(
        StateError('permission denied forever'),
      );
      expect(failure.type, AppFailureType.permissionPermanentlyDenied);
      expect(failure.canOpenSettings, isTrue);
    });

    test('maps location timeout', () {
      final failure = FailureMapper.from(
        Exception('location timed out'),
      );
      expect(failure.type, AppFailureType.locationTimeout);
    });
  });
}
