import 'package:equatable/equatable.dart';

/// One completed kilometer split recorded during a workout.
class WorkoutSplit extends Equatable {
  const WorkoutSplit({
    required this.splitIndex,
    required this.distanceMeters,
    required this.splitTimeSeconds,
    required this.averagePaceSecondsPerKm,
    required this.averageSpeedMps,
    required this.calories,
    required this.elevationGainMeters,
    required this.elevationLossMeters,
  });

  final int splitIndex;
  final double distanceMeters;
  final int splitTimeSeconds;
  final double averagePaceSecondsPerKm;
  final double averageSpeedMps;
  final int calories;
  final double elevationGainMeters;
  final double elevationLossMeters;

  int? paceChangeSecondsComparedTo(WorkoutSplit? previous) {
    if (previous == null) return null;
    return (averagePaceSecondsPerKm - previous.averagePaceSecondsPerKm).round();
  }

  Map<String, dynamic> toJson() => {
        'splitIndex': splitIndex,
        'distanceMeters': distanceMeters,
        'splitTimeSeconds': splitTimeSeconds,
        'averagePaceSecondsPerKm': averagePaceSecondsPerKm,
        'averageSpeedMps': averageSpeedMps,
        'calories': calories,
        'elevationGainMeters': elevationGainMeters,
        'elevationLossMeters': elevationLossMeters,
      };

  factory WorkoutSplit.fromJson(Map<String, dynamic> json) {
    return WorkoutSplit(
      splitIndex: (json['splitIndex'] as num).round(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      splitTimeSeconds: (json['splitTimeSeconds'] as num).round(),
      averagePaceSecondsPerKm:
          (json['averagePaceSecondsPerKm'] as num).toDouble(),
      averageSpeedMps: (json['averageSpeedMps'] as num).toDouble(),
      calories: (json['calories'] as num).round(),
      elevationGainMeters: (json['elevationGainMeters'] as num).toDouble(),
      elevationLossMeters: (json['elevationLossMeters'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        splitIndex,
        distanceMeters,
        splitTimeSeconds,
        averagePaceSecondsPerKm,
        averageSpeedMps,
        calories,
        elevationGainMeters,
        elevationLossMeters,
      ];
}
