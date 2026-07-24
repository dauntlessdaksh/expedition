import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Encodes and decodes workout polylines as JSON for Drift storage.
abstract final class PolylineCodec {
  static String encode(List<LatLng> points) {
    final payload = points
        .map(
          (point) => {
            'lat': point.latitude,
            'lng': point.longitude,
          },
        )
        .toList();

    return jsonEncode(payload);
  }

  static List<LatLng> decode(String json) {
    if (json.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(json);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (point) => LatLng(
            (point['lat'] as num).toDouble(),
            (point['lng'] as num).toDouble(),
          ),
        )
        .toList();
  }
}
