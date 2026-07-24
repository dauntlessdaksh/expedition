import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/profile_models.dart';
import '../bloc/profile_bloc.dart';
import 'profile_section_card.dart';

/// Editable workout goal preferences stored locally.
class ProfileWorkoutPreferencesSection extends StatelessWidget {
  const ProfileWorkoutPreferencesSection({
    required this.preferences,
    super.key,
  });

  final UserPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Workout Preferences',
      subtitle: 'Set your training targets',
      child: Column(
        children: [
          _GoalStepperTile(
            label: 'Daily Step Goal',
            value: preferences.dailyStepGoal,
            suffix: 'steps',
            step: 500,
            min: 1000,
            max: 30000,
            onChanged: (value) => context.read<ProfileBloc>().add(
                  UpdatePreferences(
                    PreferencesUpdateRequest(dailyStepGoal: value),
                  ),
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalStepperTile(
            label: 'Weekly Distance Goal',
            value: preferences.weeklyDistanceGoalKm.round(),
            suffix: 'km',
            step: 1,
            min: 5,
            max: 200,
            onChanged: (value) => context.read<ProfileBloc>().add(
                  UpdatePreferences(
                    PreferencesUpdateRequest(
                      weeklyDistanceGoalKm: value.toDouble(),
                    ),
                  ),
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalStepperTile(
            label: 'Weekly Workout Goal',
            value: preferences.weeklyWorkoutGoal,
            suffix: 'workouts',
            step: 1,
            min: 1,
            max: 14,
            onChanged: (value) => context.read<ProfileBloc>().add(
                  UpdatePreferences(
                    PreferencesUpdateRequest(weeklyWorkoutGoal: value),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _GoalStepperTile extends StatelessWidget {
  const _GoalStepperTile({
    required this.label,
    required this.value,
    required this.suffix,
    required this.step,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final String suffix;
  final int step;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: AppColorPalette.grey700.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColorPalette.grey400,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$value $suffix',
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: value <= min ? null : () => onChanged(value - step),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColorPalette.primaryLight,
          ),
          IconButton(
            onPressed: value >= max ? null : () => onChanged(value + step),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColorPalette.primaryLight,
          ),
        ],
      ),
    );
  }
}
