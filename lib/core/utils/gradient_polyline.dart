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
}
