import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../activity/presentation/utils/activity_formatters.dart';
import '../models/workout.dart';
import '../models/workout_pace_sample.dart';
import '../models/workout_split.dart';

/// Derives pace charts and splits from saved workout telemetry or route data.
abstract final class WorkoutAnalytics {
  static String formatPace(double secondsPerKm) {
    if (secondsPerKm <= 0 || secondsPerKm.isInfinite || secondsPerKm.isNaN) {
      return '--\'--"';
    }
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm % 60).round();
    return '$minutes\'${seconds.toString().padLeft(2, '0')}"/km';
  }

  static String formatPaceShort(double secondsPerKm) {
    if (secondsPerKm <= 0 || secondsPerKm.isInfinite || secondsPerKm.isNaN) {
      return '--\'--"';
    }
    final minutes = secondsPerKm ~/ 60;
    final seconds = (secondsPerKm % 60).round();
    return '$minutes\'${seconds.toString().padLeft(2, '0')}"';
  }

  static String formatSplitTime(int seconds) {
    return ActivityFormatters.duration(Duration(seconds: seconds));
  }

  static String formatSplitChange(int? paceChangeSeconds) {
    if (paceChangeSeconds == null) return '—';
    final sign = paceChangeSeconds >= 0 ? '+' : '−';
    final abs = paceChangeSeconds.abs();
    final minutes = abs ~/ 60;
    final seconds = abs % 60;
    if (minutes > 0) {
      return '$sign$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '$sign$seconds s';
  }

  static double averagePaceSecondsPerKm({
    required double distanceMeters,
    required int durationSeconds,
  }) {
    if (distanceMeters < 10 || durationSeconds <= 0) return 0;
    return durationSeconds / (distanceMeters / 1000);
  }

  static List<WorkoutPaceSample> resolvePaceSamples(Workout workout) {
    if (workout.paceSamples.isNotEmpty) {
      return workout.paceSamples;
    }
    return _syntheticPaceSamples(
      points: workout.polyline,
      durationSeconds: workout.durationInSeconds,
    );
  }

  static List<WorkoutSplit> resolveSplits(Workout workout) {
    if (workout.splits.isNotEmpty) {
      return workout.splits;
    }
    return _syntheticSplits(
      points: workout.polyline,
      durationSeconds: workout.durationInSeconds,
      totalCalories: workout.calories,
    );
  }

  static List<double> segmentPaces({
    required List<LatLng> points,
    required List<WorkoutPaceSample> paceSamples,
    required int durationSeconds,
  }) {
    if (points.length < 2) {
      return const [];
    }

    if (paceSamples.length >= points.length - 1) {
      return paceSamples
          .take(points.length - 1)
          .map((sample) => sample.paceSecondsPerKm)
          .toList();
    }

    final segmentDistances = _segmentDistances(points);
    final totalDistance = segmentDistances.fold<double>(0, (a, b) => a + b);
    if (totalDistance <= 0 || durationSeconds <= 0) {
      return List<double>.filled(points.length - 1, 0);
    }

    return segmentDistances
        .map(
          (distance) => distance <= 0
              ? 0.0
              : (durationSeconds * (distance / totalDistance)) /
                  (distance / 1000),
        )
        .toList();
  }

  static List<WorkoutPaceSample> _syntheticPaceSamples({
    required List<LatLng> points,
    required int durationSeconds,
    int intervalSeconds = 10,
  }) {
    if (points.length < 2 || durationSeconds <= 0) {
      return const [];
    }

    final segmentDistances = _segmentDistances(points);
    final totalDistance = segmentDistances.fold<double>(0, (a, b) => a + b);
    if (totalDistance <= 0) {
      return const [];
    }

    final samples = <WorkoutPaceSample>[];
    for (var elapsed = 0;
        elapsed <= durationSeconds;
        elapsed += intervalSeconds) {
      final progress = elapsed / durationSeconds;
      final distance = totalDistance * progress;
      final speed = elapsed > 0 ? distance / elapsed : 0.0;
      final pace = speed > 0.3 ? 1000 / speed : 0.0;

      samples.add(
        WorkoutPaceSample(
          elapsedTimeSeconds: elapsed,
          paceSecondsPerKm: pace,
          speedMps: speed,
          distanceMeters: distance,
          timestamp: DateTime.now(),
        ),
      );
    }

    return samples;
  }

  static List<WorkoutSplit> _syntheticSplits({
    required List<LatLng> points,
    required int durationSeconds,
    required int totalCalories,
  }) {
    if (points.length < 2 || durationSeconds <= 0) {
      return const [];
    }

    final segmentDistances = _segmentDistances(points);
    final totalDistance = segmentDistances.fold<double>(0, (a, b) => a + b);
    if (totalDistance < 1000) {
      return const [];
    }

    final splits = <WorkoutSplit>[];
    var kmTarget = 1000.0;
    var kmStartTime = 0.0;
    var timeCursor = 0.0;
    var distanceCursor = 0.0;

    for (var i = 0; i < segmentDistances.length; i++) {
      final segDist = segmentDistances[i];
      final segDuration = durationSeconds * (segDist / totalDistance);
      final segEndDistance = distanceCursor + segDist;
      final segEndTime = timeCursor + segDuration;

      while (segEndDistance >= kmTarget) {
        final remainingToKm = kmTarget - distanceCursor;
        final fraction = segDist > 0 ? remainingToKm / segDist : 0.0;
        final splitEndTime = timeCursor + segDuration * fraction;
        final splitDuration = (splitEndTime - kmStartTime).round();
        final pace = splitDuration.toDouble();

        splits.add(
          WorkoutSplit(
            splitIndex: splits.length + 1,
            distanceMeters: 1000,
            splitTimeSeconds: splitDuration,
            averagePaceSecondsPerKm: pace,
            averageSpeedMps: splitDuration > 0 ? 1000 / splitDuration : 0,
            calories: totalCalories > 0
                ? (totalCalories / (totalDistance / 1000)).round()
                : 0,
            elevationGainMeters: 0,
            elevationLossMeters: 0,
          ),
        );

        kmStartTime = splitEndTime;
        kmTarget += 1000;
      }

      distanceCursor = segEndDistance;
      timeCursor = segEndTime;
    }

    return splits;
  }

  static List<double> _segmentDistances(List<LatLng> points) {
    final distances = <double>[];
    for (var i = 1; i < points.length; i++) {
      distances.add(
        Geolocator.distanceBetween(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude,
        ),
      );
    }
    return distances;
  }
}
