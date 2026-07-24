import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';

/// Builds a single live-route polyline for map tracking (O(1) object count).
abstract final class ActivityRoutePolyline {
  static const _polylineId = PolylineId('activity_route');

  static Set<Polyline> build(List<LatLng> points) {
    if (points.length < 2) {
      return const {};
    }

    return {
      Polyline(
        polylineId: _polylineId,
        points: points,
        color: AppColorPalette.primary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }
}
