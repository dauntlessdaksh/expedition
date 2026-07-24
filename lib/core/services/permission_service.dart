import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Location permission states used by activity tracking flows.
enum LocationAccessStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Handles permission checks and deep links into system settings.
abstract final class PermissionService {
  static Future<LocationAccessStatus> checkLocationAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessStatus.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse =>
        LocationAccessStatus.granted,
      LocationPermission.deniedForever => LocationAccessStatus.deniedForever,
      LocationPermission.denied => LocationAccessStatus.denied,
      LocationPermission.unableToDetermine => LocationAccessStatus.denied,
    };
  }

  static Future<bool> openAppSettings() => ph.openAppSettings();

  static Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
