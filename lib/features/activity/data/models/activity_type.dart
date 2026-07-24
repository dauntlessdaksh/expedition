import 'package:flutter/material.dart';

/// Outdoor activity types supported by the tracker.
enum ActivityType {
  walk,
  run,
  hike,
  cycling;

  String get label => switch (this) {
        ActivityType.walk => 'Walk',
        ActivityType.run => 'Run',
        ActivityType.hike => 'Hike',
        ActivityType.cycling => 'Cycling',
      };

  String get emoji => switch (this) {
        ActivityType.walk => '🚶',
        ActivityType.run => '🏃',
        ActivityType.hike => '🥾',
        ActivityType.cycling => '🚴',
      };

  IconData get icon => switch (this) {
        ActivityType.walk => Icons.directions_walk_rounded,
        ActivityType.run => Icons.directions_run_rounded,
        ActivityType.hike => Icons.hiking_rounded,
        ActivityType.cycling => Icons.directions_bike_rounded,
      };

  Color get accentColor => switch (this) {
        ActivityType.walk => const Color(0xFF4ADE80),
        ActivityType.run => const Color(0xFFFB923C),
        ActivityType.hike => const Color(0xFFA78BFA),
        ActivityType.cycling => const Color(0xFF60A5FA),
      };

  String get storageValue => name;

  static ActivityType fromStorage(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.storageValue == value || type.name == value,
      orElse: () => ActivityType.run,
    );
  }
}
