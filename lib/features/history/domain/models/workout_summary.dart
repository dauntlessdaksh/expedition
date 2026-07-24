import 'package:equatable/equatable.dart';

/// Lightweight workout row for aggregates — skips polyline/telemetry decoding.
class WorkoutSummary extends Equatable {
  const WorkoutSummary({
    this.id,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
    required this.distanceInMeters,
    required this.calories,
  });

  final int? id;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInSeconds;
  final double distanceInMeters;
  final int calories;

  @override
  List<Object?> get props => [
        id,
        activityType,
        startTime,
        endTime,
        durationInSeconds,
        distanceInMeters,
        calories,
      ];
}
