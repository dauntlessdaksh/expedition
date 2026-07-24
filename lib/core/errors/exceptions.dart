/// Base class for application-specific exceptions thrown in the data layer.
class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Thrown when a network request fails.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network request failed',
    super.code,
  });
}

/// Thrown when a local cache or database operation fails.
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache operation failed',
    super.code,
  });
}

/// Thrown when input validation fails.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });
}

/// Thrown when location services are unavailable or denied.
class LocationException extends AppException {
  const LocationException({
    super.message = 'Location service unavailable',
    super.code,
  });
}

/// Thrown for unexpected errors that do not fit other categories.
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}
