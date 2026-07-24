import 'package:flutter/material.dart';

/// Fitness goal selected during onboarding.
enum FitnessGoal {
  loseWeight,
  stayActive,
  buildMuscle,
  improveEndurance;

  String get label => switch (this) {
        FitnessGoal.loseWeight => 'Lose Weight',
        FitnessGoal.stayActive => 'Stay Active',
        FitnessGoal.buildMuscle => 'Build Muscle',
        FitnessGoal.improveEndurance => 'Improve Endurance',
      };

  String get description => switch (this) {
        FitnessGoal.loseWeight => 'Burn calories and reach your target weight',
        FitnessGoal.stayActive => 'Maintain a healthy and active lifestyle',
        FitnessGoal.buildMuscle => 'Gain strength with focused training',
        FitnessGoal.improveEndurance => 'Boost stamina for longer sessions',
      };

  IconData get icon => switch (this) {
        FitnessGoal.loseWeight => Icons.local_fire_department_outlined,
        FitnessGoal.stayActive => Icons.directions_walk_outlined,
        FitnessGoal.buildMuscle => Icons.fitness_center_outlined,
        FitnessGoal.improveEndurance => Icons.timer_outlined,
      };

  String get storageValue => name;
}
