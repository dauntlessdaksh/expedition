import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'gps_tracking_state.dart';

/// Processed GPS snapshot consumed by activity tracking UI and persistence.
class FilteredLocation extends Equatable {
  const FilteredLocation({
    required this.position,
    required this.accuracy,
    required this.currentSpeed,
    required this.averageSpeed,
    required this.totalDistance,
    required this.movingTime,
    required this.elapsedTime,
    required this.isMoving,
    required this.trackingState,
    required this.hasGpsLock,
    required this.timestamp,
    required this.polyline,
    required this.maxSpeed,
  });

  final LatLng position;
  final double accuracy;
  final double currentSpeed;
  final double averageSpeed;
  final double totalDistance;
  final Duration movingTime;
  final Duration elapsedTime;
  final bool isMoving;
  final GpsTrackingState trackingState;
  final bool hasGpsLock;
  final DateTime timestamp;
  final List<LatLng> polyline;
  final double maxSpeed;

  bool get isActivelyTracking =>
      trackingState == GpsTrackingState.tracking;

  FilteredLocation copyWith({
    LatLng? position,
    double? accuracy,
    double? currentSpeed,
    double? averageSpeed,
    double? totalDistance,
    Duration? movingTime,
    Duration? elapsedTime,
    bool? isMoving,
    GpsTrackingState? trackingState,
    bool? hasGpsLock,
    DateTime? timestamp,
    List<LatLng>? polyline,
    double? maxSpeed,
  }) {
    return FilteredLocation(
      position: position ?? this.position,
      accuracy: accuracy ?? this.accuracy,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      totalDistance: totalDistance ?? this.totalDistance,
      movingTime: movingTime ?? this.movingTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isMoving: isMoving ?? this.isMoving,
      trackingState: trackingState ?? this.trackingState,
      hasGpsLock: hasGpsLock ?? this.hasGpsLock,
      timestamp: timestamp ?? this.timestamp,
      polyline: polyline ?? this.polyline,
      maxSpeed: maxSpeed ?? this.maxSpeed,
    );
  }

  @override
  List<Object?> get props => [
        position,
        accuracy,
        currentSpeed,
        averageSpeed,
        totalDistance,
        movingTime,
        elapsedTime,
        isMoving,
        trackingState,
        hasGpsLock,
        timestamp,
        polyline,
        maxSpeed,
      ];
}

/// Outcome of processing one raw GPS fix through the engine pipeline.
enum GpsRejectReason {
  sessionInactive,
  accuracy,
  time,
  distance,
  impossibleSpeed,
  stationary,
}

/// Result returned by [GpsEngine.process].
class GpsProcessResult extends Equatable {
  const GpsProcessResult({
    required this.location,
    this.rejectReason,
  });

  const GpsProcessResult.rejected(GpsRejectReason reason)
      : location = null,
        rejectReason = reason;

  const GpsProcessResult.accepted(FilteredLocation location)
      : location = location,
        rejectReason = null;

  final FilteredLocation? location;
  final GpsRejectReason? rejectReason;

  bool get wasAccepted => rejectReason == null && location != null;

  @override
  List<Object?> get props => [location, rejectReason];
}
