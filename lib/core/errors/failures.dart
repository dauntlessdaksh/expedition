import 'package:equatable/equatable.dart';

/// Base class for domain-level failures returned to the presentation layer.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Failure caused by network connectivity or HTTP errors.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network request failed',
    super.code,
  });
}

/// Failure caused by local cache or database operations.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache operation failed',
    super.code,
  });
}

/// Failure caused by invalid user input or business rule violations.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Failure caused by location or GPS services.
class LocationFailure extends Failure {
  const LocationFailure({
    super.message = 'Location service unavailable',
    super.code,
  });
}

/// Catch-all failure for unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}
