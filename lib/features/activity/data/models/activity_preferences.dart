import 'package:equatable/equatable.dart';

import 'activity_type.dart';

/// Locally persisted activity screen preferences.
class ActivityPreferences extends Equatable {
  const ActivityPreferences({
    this.activityType = ActivityType.run,
    this.distanceGoalKm = 5,
    this.timeGoalMinutes = 30,
    this.countdownEnabled = true,
    this.countdownSeconds = 3,
    this.autoPause = true,
    this.vibration = true,
  });

  final ActivityType activityType;
  final double distanceGoalKm;
  final int timeGoalMinutes;
  final bool countdownEnabled;
  final int countdownSeconds;
  final bool autoPause;
  final bool vibration;

  static const defaults = ActivityPreferences();

  ActivityPreferences copyWith({
    ActivityType? activityType,
    double? distanceGoalKm,
    int? timeGoalMinutes,
    bool? countdownEnabled,
    int? countdownSeconds,
    bool? autoPause,
    bool? vibration,
  }) {
    return ActivityPreferences(
      activityType: activityType ?? this.activityType,
      distanceGoalKm: distanceGoalKm ?? this.distanceGoalKm,
      timeGoalMinutes: timeGoalMinutes ?? this.timeGoalMinutes,
      countdownEnabled: countdownEnabled ?? this.countdownEnabled,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      autoPause: autoPause ?? this.autoPause,
      vibration: vibration ?? this.vibration,
    );
  }

  Map<String, dynamic> toJson() => {
        'activityType': activityType.storageValue,
        'distanceGoalKm': distanceGoalKm,
        'timeGoalMinutes': timeGoalMinutes,
        'countdownEnabled': countdownEnabled,
        'countdownSeconds': countdownSeconds,
        'autoPause': autoPause,
        'vibration': vibration,
      };

  factory ActivityPreferences.fromJson(Map<String, dynamic> json) {
    return ActivityPreferences(
      activityType: ActivityType.fromStorage(
        json['activityType'] as String? ?? 'run',
      ),
      distanceGoalKm: (json['distanceGoalKm'] as num?)?.toDouble() ?? 5,
      timeGoalMinutes: json['timeGoalMinutes'] as int? ?? 30,
      countdownEnabled: json['countdownEnabled'] as bool? ?? true,
      countdownSeconds: json['countdownSeconds'] as int? ?? 3,
      autoPause: json['autoPause'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        activityType,
        distanceGoalKm,
        timeGoalMinutes,
        countdownEnabled,
        countdownSeconds,
        autoPause,
        vibration,
      ];
}
