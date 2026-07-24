import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../activity/presentation/widgets/map_dark_style.dart';
import '../../../../core/constants/app_colors.dart';

/// Static Google Map that renders a saved workout route polyline.
class WorkoutRouteMap extends StatefulWidget {
  const WorkoutRouteMap({
    required this.routePoints,
    super.key,
  });

  final List<LatLng> routePoints;

  @override
  State<WorkoutRouteMap> createState() => _WorkoutRouteMapState();
}

class _WorkoutRouteMapState extends State<WorkoutRouteMap> {
  GoogleMapController? _controller;

  static const _fallbackPosition = LatLng(28.6139, 77.2090);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.routePoints;
    final initialTarget = points.isNotEmpty ? points.first : _fallbackPosition;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 14,
      ),
      style: MapDarkStyle.json,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      polylines: points.length >= 2
          ? {
              Polyline(
                polylineId: const PolylineId('saved_route'),
                points: points,
                color: AppColorPalette.primary,
                width: 5,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            }
          : const {},
      onMapCreated: (controller) async {
        _controller = controller;
        if (points.length >= 2) {
          await _fitRoute(points);
        }
      },
    );
  }

  Future<void> _fitRoute(List<LatLng> points) async {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 48),
    );
  }
}
