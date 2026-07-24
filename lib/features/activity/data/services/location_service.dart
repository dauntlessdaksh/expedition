import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../../core/services/permission_service.dart';

/// Wraps geolocator and permission checks for live activity tracking.
class LocationService {
  static const _locationTimeout = Duration(seconds: 12);

  Future<LocationAccessStatus> checkAccess() {
    return PermissionService.checkLocationAccess();
  }

  Future<bool> ensurePermission() async {
    final access = await checkAccess();
    return access == LocationAccessStatus.granted;
  }

  Future<Position?> getCurrentPosition() async {
    final access = await checkAccess();
    if (access != LocationAccessStatus.granted) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).timeout(_locationTimeout);
  }

  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3,
      ),
    );
  }
}
