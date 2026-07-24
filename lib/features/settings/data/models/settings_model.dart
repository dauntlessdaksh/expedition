import 'package:equatable/equatable.dart';

/// Domain model for application settings.
class SettingsModel extends Equatable {
  const SettingsModel({
    required this.id,
    required this.theme,
    required this.unit,
    required this.notificationsEnabled,
    required this.dailyStepGoal,
  });

  final int id;
  final String theme;
  final String unit;
  final bool notificationsEnabled;
  final int dailyStepGoal;

  @override
  List<Object?> get props => [
        id,
        theme,
        unit,
        notificationsEnabled,
        dailyStepGoal,
      ];
}
