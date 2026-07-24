import 'dart:convert';

import '../../domain/models/workout_pace_sample.dart';
import '../../domain/models/workout_split.dart';

/// JSON codec for persisted workout telemetry payloads.
abstract final class WorkoutTelemetryCodec {
  static String encode({
    required List<WorkoutPaceSample> paceSamples,
    required List<WorkoutSplit> splits,
    required double averageGpsAccuracyMeters,
  }) {
    return jsonEncode({
      'paceSamples': paceSamples.map((sample) => sample.toJson()).toList(),
      'splits': splits.map((split) => split.toJson()).toList(),
      'averageGpsAccuracyMeters': averageGpsAccuracyMeters,
    });
  }

  static ({
    List<WorkoutPaceSample> paceSamples,
    List<WorkoutSplit> splits,
    double averageGpsAccuracyMeters,
  }) decode(String? json) {
    if (json == null || json.trim().isEmpty || json.trim() == '{}') {
      return (
        paceSamples: const <WorkoutPaceSample>[],
        splits: const <WorkoutSplit>[],
        averageGpsAccuracyMeters: 0,
      );
    }

    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      return (
        paceSamples: const <WorkoutPaceSample>[],
        splits: const <WorkoutSplit>[],
        averageGpsAccuracyMeters: 0,
      );
    }

    final paceSamples = (decoded['paceSamples'] as List? ?? const [])
        .whereType<Map>()
        .map((entry) => WorkoutPaceSample.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    final splits = (decoded['splits'] as List? ?? const [])
        .whereType<Map>()
        .map((entry) => WorkoutSplit.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    return (
      paceSamples: paceSamples,
      splits: splits,
      averageGpsAccuracyMeters:
          (decoded['averageGpsAccuracyMeters'] as num?)?.toDouble() ?? 0,
    );
  }
}
