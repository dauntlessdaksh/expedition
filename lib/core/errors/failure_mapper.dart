import '../constants/app_strings.dart';
import 'app_failure.dart';

/// Maps thrown errors into consistent, recoverable [AppFailure] instances.
abstract final class FailureMapper {
  static AppFailure from(Object error, {String? fallbackMessage}) {
    if (error is AppFailure) {
      return error;
    }

    final message = error.toString().toLowerCase();

    if (message.contains('sqlite') ||
        message.contains('drift') ||
        message.contains('database')) {
      return const AppFailure(
        type: AppFailureType.database,
        title: 'Storage unavailable',
        message:
            'Expedition could not read or write local data. Please retry.',
        canRetry: true,
      );
    }

    if (message.contains('permission') && message.contains('forever')) {
      return const AppFailure(
        type: AppFailureType.permissionPermanentlyDenied,
        title: 'Location access blocked',
        message:
            'Location permission was permanently denied. Open Settings to allow access for activity tracking.',
        canRetry: false,
        canOpenSettings: true,
      );
    }

    if (message.contains('permission denied') ||
        message.contains('location permission')) {
      return const AppFailure(
        type: AppFailureType.permissionDenied,
        title: 'Location permission required',
        message:
            'Expedition needs location access to track outdoor activities accurately.',
        canRetry: true,
        canOpenSettings: true,
      );
    }

    if (message.contains('location service') ||
        message.contains('service disabled')) {
      return const AppFailure(
        type: AppFailureType.locationServiceDisabled,
        title: 'Location services disabled',
        message:
            'Turn on device location services to start tracking your workout.',
        canRetry: true,
        canOpenSettings: true,
      );
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return const AppFailure(
        type: AppFailureType.locationTimeout,
        title: 'Location timed out',
        message:
            'We could not get a GPS fix in time. Move to an open area and try again.',
        canRetry: true,
      );
    }

    if (message.contains('gps') ||
        message.contains('position') ||
        message.contains('location unavailable')) {
      return const AppFailure(
        type: AppFailureType.gpsUnavailable,
        title: 'GPS unavailable',
        message:
            'Unable to determine your location right now. Check signal and try again.',
        canRetry: true,
      );
    }

    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('connection')) {
      return const AppFailure(
        type: AppFailureType.network,
        title: 'Connection issue',
        message: AppStrings.networkError,
        canRetry: true,
      );
    }

    return AppFailure(
      type: AppFailureType.unknown,
      title: 'Something went wrong',
      message: fallbackMessage ?? AppStrings.genericError,
      canRetry: true,
    );
  }
}
