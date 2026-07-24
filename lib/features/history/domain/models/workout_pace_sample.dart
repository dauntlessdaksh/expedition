import 'package:equatable/equatable.dart';

/// A pace snapshot captured approximately every 10 seconds during a workout.
class WorkoutPaceSample extends Equatable {
  const WorkoutPaceSample({
    required this.elapsedTimeSeconds,
    required this.paceSecondsPerKm,
    required this.speedMps,
    required this.distanceMeters,
    required this.timestamp,
  });

  final int elapsedTimeSeconds;
  final double paceSecondsPerKm;
  final double speedMps;
  final double distanceMeters;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'elapsedTimeSeconds': elapsedTimeSeconds,
        'paceSecondsPerKm': paceSecondsPerKm,
        'speedMps': speedMps,
        'distanceMeters': distanceMeters,
        'timestamp': timestamp.toIso8601String(),
      };

  factory WorkoutPaceSample.fromJson(Map<String, dynamic> json) {
    return WorkoutPaceSample(
      elapsedTimeSeconds: (json['elapsedTimeSeconds'] as num).round(),
      paceSecondsPerKm: (json['paceSecondsPerKm'] as num).toDouble(),
      speedMps: (json['speedMps'] as num).toDouble(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [
        elapsedTimeSeconds,
        paceSecondsPerKm,
        speedMps,
        distanceMeters,
        timestamp,
      ];
}
