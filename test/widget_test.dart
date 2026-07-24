import 'package:flutter_test/flutter_test.dart';

import 'package:expedition/core/constants/app_strings.dart';
import 'package:expedition/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required returns error for empty value', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required(null), isNotNull);
    });

    test('required returns null for non-empty value', () {
      expect(Validators.required('hello'), isNull);
    });

    test('email validates correctly', () {
      expect(Validators.email('invalid'), isNotNull);
      expect(Validators.email('test@example.com'), isNull);
    });
  });

  group('AppStrings', () {
    test('app name is Expedition', () {
      expect(AppStrings.appName, 'Expedition');
    });
  });
}
