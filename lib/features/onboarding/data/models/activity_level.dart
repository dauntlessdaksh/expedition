import 'package:flutter/material.dart';

/// Activity level selected during onboarding.
enum ActivityLevel {
  beginner,
  intermediate,
  advanced;

  String get label => switch (this) {
        ActivityLevel.beginner => 'Beginner',
        ActivityLevel.intermediate => 'Intermediate',
        ActivityLevel.advanced => 'Advanced',
      };

  String get description => switch (this) {
        ActivityLevel.beginner => 'Just starting your fitness journey',
        ActivityLevel.intermediate => 'Regular workouts, building consistency',
        ActivityLevel.advanced => 'High intensity, experienced athlete',
      };

  IconData get icon => switch (this) {
        ActivityLevel.beginner => Icons.eco_outlined,
        ActivityLevel.intermediate => Icons.trending_up_outlined,
        ActivityLevel.advanced => Icons.bolt_outlined,
      };

  String get storageValue => name;
}
