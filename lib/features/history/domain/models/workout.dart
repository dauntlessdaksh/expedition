import 'package:drift/drift.dart' show Value;
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/database/app_database.dart';
import '../../../shared/utils/polyline_codec.dart';
import 'workout_pace_sample.dart';
import 'workout_split.dart';

/// Domain model for a persisted workout session.
class Workout extends Equatable {
  const Workout({
    this.id,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
    required this.distanceInMeters,
    required this.averageSpeed,
    required this.maxSpeed,
    required this.calories,
    required this.polyline,
    required this.createdAt,
    this.paceSamples = const [],
    this.splits = const [],
  });

  final int? id;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInSeconds;
  final double distanceInMeters;
  final double averageSpeed;
  final double maxSpeed;
  final int calories;
  final List<LatLng> polyline;
  final DateTime createdAt;
  final List<WorkoutPaceSample> paceSamples;
  final List<WorkoutSplit> splits;

  /// Defaults until telemetry columns are persisted.
  int get movingTimeInSeconds => durationInSeconds;
  double get elevationGainMeters => 0;
  double get elevationLossMeters => 0;
  double get highestElevationMeters => 0;
  double get lowestElevationMeters => 0;

  factory Workout.fromRow(WorkoutRow row) {
    return Workout(
      id: row.id,
      activityType: row.activityType,
      startTime: row.startTime,
      endTime: row.endTime,
      durationInSeconds: row.durationInSeconds,
      distanceInMeters: row.distanceInMeters,
      averageSpeed: row.averageSpeed,
      maxSpeed: row.maxSpeed,
      calories: row.calories,
      polyline: PolylineCodec.decode(row.polyline),
      createdAt: row.createdAt,
    );
  }

  WorkoutsCompanion toCompanion({bool omitId = true}) {
    return WorkoutsCompanion(
      id: omitId ? const Value.absent() : Value(id!),
      activityType: Value(activityType),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationInSeconds: Value(durationInSeconds),
      distanceInMeters: Value(distanceInMeters),
      averageSpeed: Value(averageSpeed),
      maxSpeed: Value(maxSpeed),
      calories: Value(calories),
      polyline: Value(PolylineCodec.encode(polyline)),
      createdAt: Value(createdAt),
    );
  }

  Workout copyWith({
    int? id,
    List<WorkoutPaceSample>? paceSamples,
    List<WorkoutSplit>? splits,
  }) {
    return Workout(
      id: id ?? this.id,
      activityType: activityType,
      startTime: startTime,
      endTime: endTime,
      durationInSeconds: durationInSeconds,
      distanceInMeters: distanceInMeters,
      averageSpeed: averageSpeed,
      maxSpeed: maxSpeed,
      calories: calories,
      polyline: polyline,
      createdAt: createdAt,
      paceSamples: paceSamples ?? this.paceSamples,
      splits: splits ?? this.splits,
    );
  }

  @override
  List<Object?> get props => [
        id,
        activityType,
        startTime,
        endTime,
        durationInSeconds,
        distanceInMeters,
        averageSpeed,
        maxSpeed,
        calories,
        polyline,
        createdAt,
        paceSamples,
        splits,
      ];
}
