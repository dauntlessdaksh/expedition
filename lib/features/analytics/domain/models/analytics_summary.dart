import 'package:equatable/equatable.dart';

/// Top-level lifetime workout totals for the analytics dashboard.
class AnalyticsSummary extends Equatable {
  const AnalyticsSummary({
    required this.totalDistanceMeters,
    required this.totalWorkouts,
    required this.totalActiveSeconds,
    required this.totalCalories,
  });

  final double totalDistanceMeters;
  final int totalWorkouts;
  final int totalActiveSeconds;
  final int totalCalories;

  double get totalDistanceKm => totalDistanceMeters / 1000;

  int get totalActiveMinutes => totalActiveSeconds ~/ 60;

  @override
  List<Object?> get props => [
        totalDistanceMeters,
        totalWorkouts,
        totalActiveSeconds,
        totalCalories,
      ];
}
