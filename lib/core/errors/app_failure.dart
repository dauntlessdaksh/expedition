import 'package:equatable/equatable.dart';

/// Typed application failures mapped to user-facing recovery actions.
enum AppFailureType {
  database,
  permissionDenied,
  permissionPermanentlyDenied,
  gpsUnavailable,
  locationTimeout,
  locationServiceDisabled,
  network,
  unknown,
}

/// User-facing failure with optional recovery action metadata.
final class AppFailure extends Equatable {
  const AppFailure({
    required this.type,
    required this.title,
    required this.message,
    this.canRetry = true,
    this.canOpenSettings = false,
  });

  final AppFailureType type;
  final String title;
  final String message;
  final bool canRetry;
  final bool canOpenSettings;

  @override
  List<Object?> get props => [
        type,
        title,
        message,
        canRetry,
        canOpenSettings,
      ];
}
