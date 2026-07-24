import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Why a raw GPS fix was rejected by the filter pipeline.
enum LocationFilterRejectReason {
  updateTooSoon,
  accuracyTooLow,
  stationary,
  impossibleJump,
}

/// A GPS fix that passed the filter pipeline.
class AcceptedLocationFix extends Equatable {
  const AcceptedLocationFix({
    required this.position,
    required this.timestamp,
    required this.instantSpeedMps,
    required this.smoothedSpeedMps,
  });

  final Position position;
  final DateTime timestamp;
  final double instantSpeedMps;
  final double smoothedSpeedMps;

  LatLng get latLng => LatLng(position.latitude, position.longitude);

  @override
  List<Object?> get props => [
        position.latitude,
        position.longitude,
        timestamp,
        instantSpeedMps,
        smoothedSpeedMps,
      ];
}

/// Aggregated metrics derived from accepted GPS fixes only.
class LocationFilterMetrics extends Equatable {
  const LocationFilterMetrics({
    this.totalDistanceMeters = 0,
    this.movingTime = Duration.zero,
    this.currentSpeedMps = 0,
    this.averageSpeedMps = 0,
    this.maxSpeedMps = 0,
    this.routePoints = const [],
  });

  final double totalDistanceMeters;
  final Duration movingTime;
  final double currentSpeedMps;
  final double averageSpeedMps;
  final double maxSpeedMps;
  final List<LatLng> routePoints;

  @override
  List<Object?> get props => [
        totalDistanceMeters,
        movingTime,
        currentSpeedMps,
        averageSpeedMps,
        maxSpeedMps,
        routePoints,
      ];
}

/// Result of processing one raw GPS fix through the filter pipeline.
class FilteredLocationUpdate extends Equatable {
  const FilteredLocationUpdate({
    required this.rawPosition,
    required this.metrics,
    this.accepted,
    this.rejectReason,
    this.polylinePointAdded,
  });

  final Position rawPosition;
  final AcceptedLocationFix? accepted;
  final LocationFilterMetrics metrics;
  final LocationFilterRejectReason? rejectReason;
  final LatLng? polylinePointAdded;

  bool get wasAccepted => accepted != null;

  @override
  List<Object?> get props => [
        rawPosition.latitude,
        rawPosition.longitude,
        rawPosition.timestamp,
        accepted,
        metrics,
        rejectReason,
        polylinePointAdded,
      ];
}
