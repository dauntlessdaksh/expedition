import 'package:equatable/equatable.dart';

/// Persisted fitness goal with computed progress.
class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    required this.period,
    required this.periodStart,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final double targetValue;
  final double currentValue;
  final String period;
  final DateTime periodStart;
  final DateTime updatedAt;

  double get progress =>
      targetValue <= 0 ? 0 : (currentValue / targetValue).clamp(0.0, 1.0);

  int get progressPercent => (progress * 100).round();

  bool get isCompleted => currentValue >= targetValue;

  @override
  List<Object?> get props => [
        id,
        title,
        targetValue,
        currentValue,
        period,
        periodStart,
        updatedAt,
      ];
}

/// Generated or active fitness challenge.
class Challenge extends Equatable {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final double targetValue;
  final double currentValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final DateTime? completedAt;

  double get progress =>
      targetValue <= 0 ? 0 : (currentValue / targetValue).clamp(0.0, 1.0);

  int get progressPercent => (progress * 100).round();

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        targetValue,
        currentValue,
        startDate,
        endDate,
        isCompleted,
        completedAt,
      ];
}
