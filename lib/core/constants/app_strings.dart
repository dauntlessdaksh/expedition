/// Application-wide string constants.
abstract final class AppStrings {
  static const String appName = 'Expedition';

  // General
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String ok = 'OK';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 8 characters';

  // Errors
  static const String genericError =
      'Something went wrong. Please try again.';
  static const String networkError =
      'Unable to connect. Check your internet connection.';
  static const String cacheError = 'Unable to load cached data.';
}
