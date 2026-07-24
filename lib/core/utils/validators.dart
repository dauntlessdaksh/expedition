/// Utility class for common input validation rules.
abstract final class Validators {
  /// Returns an error message if [value] is null or empty, otherwise null.
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  /// Returns an error message if [value] is not a valid email address.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Returns an error message if [value] is shorter than [minLength].
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      final label = fieldName ?? 'This field';
      return '$label must be at least $minLength characters';
    }
    return null;
  }

  /// Returns an error message if [value] is not a positive number.
  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) return null;

    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Please enter a valid positive number';
    }
    return null;
  }

  /// Combines multiple validators and returns the first error found.
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
