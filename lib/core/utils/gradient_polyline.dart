import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/app_colors.dart';
import '../theme/premium_gradients.dart';

/// Builds multi-segment polylines with a performance gradient (green → red).
abstract final class GradientPolyline {
  static Set<Polyline> build(
    List<LatLng> points, {
    int width = 5,
    String idPrefix = 'route',
  }) {
    if (points.length < 2) {
      return const {};
    }

    final polylines = <Polyline>{};
    final segmentCount = points.length - 1;

    for (var i = 0; i < segmentCount; i++) {
      final progress = segmentCount == 1 ? 1.0 : i / (segmentCount - 1);

      polylines.add(
        Polyline(
          polylineId: PolylineId('${idPrefix}_$i'),
          points: [points[i], points[i + 1]],
          color: _colorAt(progress),
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return polylines;
  }

  static Color _colorAt(double t) {
    final colors = PremiumGradients.routeGradient;
    if (t <= 0) return colors.first;
    if (t >= 1) return colors.last;

    final scaled = t * (colors.length - 1);
    final index = scaled.floor().clamp(0, colors.length - 2);
    final localT = scaled - index;

    return Color.lerp(colors[index], colors[index + 1], localT) ??
        AppColorPalette.routeRed;
  }

  /// Builds a pace-colored route where fast segments are green and slow are red.
  static Set<Polyline> buildByPace(
    List<LatLng> points,
    List<double> paceSecondsPerKm, {
    int width = 5,
    String idPrefix = 'route',
  }) {
    if (points.length < 2) {
      return const {};
    }

    final validPaces = paceSecondsPerKm.where((pace) => pace > 0).toList();
    if (validPaces.isEmpty) {
      return build(points, width: width, idPrefix: idPrefix);
    }

    final minPace = validPaces.reduce((a, b) => a < b ? a : b);
    final maxPace = validPaces.reduce((a, b) => a > b ? a : b);
    final range = (maxPace - minPace).clamp(1, double.infinity);

    final polylines = <Polyline>{};
    final segmentCount = points.length - 1;

    for (var i = 0; i < segmentCount; i++) {
      final pace = i < paceSecondsPerKm.length ? paceSecondsPerKm[i] : 0;
      final normalized = pace <= 0
          ? 0.5
          : ((pace - minPace) / range).clamp(0.0, 1.0);

      polylines.add(
        Polyline(
          polylineId: PolylineId('${idPrefix}_$i'),
          points: [points[i], points[i + 1]],
          color: _colorAt(normalized),
          width: width,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return polylines;
  }
}
