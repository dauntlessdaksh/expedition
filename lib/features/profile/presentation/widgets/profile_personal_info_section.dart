import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../onboarding/data/models/activity_level.dart';
import '../../../onboarding/data/models/fitness_goal.dart';
import '../../../onboarding/data/models/gender.dart';
import '../../../onboarding/presentation/widgets/onboarding_inputs.dart';
import '../../../onboarding/presentation/widgets/onboarding_option_card.dart';
import '../../../onboarding/presentation/widgets/onboarding_wheel_picker.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/profile_data.dart';
import '../../domain/models/profile_models.dart';
import '../bloc/profile_bloc.dart';
import 'profile_section_card.dart';

/// Editable personal information section.
class ProfilePersonalInfoSection extends StatefulWidget {
  const ProfilePersonalInfoSection({
    required this.data,
    super.key,
  });

  final ProfileData data;

  @override
  State<ProfilePersonalInfoSection> createState() =>
      _ProfilePersonalInfoSectionState();
}

class _ProfilePersonalInfoSectionState
    extends State<ProfilePersonalInfoSection> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.profile.name);
  }

  @override
  void didUpdateWidget(covariant ProfilePersonalInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.profile.name != widget.data.profile.name &&
        _nameController.text != widget.data.profile.name) {
      _nameController.text = widget.data.profile.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.data.profile;
    final gender = ProfileValueParser.gender(profile.gender);
    final fitnessGoal = ProfileValueParser.fitnessGoal(profile.fitnessGoal);
    final activityLevel =
        ProfileValueParser.activityLevel(profile.activityLevel);

    return ProfileSectionCard(
      title: 'Personal Information',
      subtitle: 'Update your profile details',
      child: Column(
        children: [
          OnboardingTextField(
            controller: _nameController,
            hint: 'Your name',
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.md),
          ProfileFieldTile(
            label: 'Age',
            value: '${profile.age} years',
            onTap: () => _showAgePicker(context, profile.age),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileFieldTile(
            label: 'Height',
            value: '${profile.height.round()} cm',
            onTap: () => _showHeightPicker(context, profile.height),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileFieldTile(
            label: 'Weight',
            value: '${profile.weight.round()} kg',
            onTap: () => _showWeightPicker(context, profile.weight),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileFieldTile(
            label: 'Gender',
            value: gender.label,
            onTap: () => _showGenderPicker(context, gender),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileFieldTile(
            label: 'Fitness Goal',
            value: fitnessGoal.label,
            onTap: () => _showFitnessGoalPicker(context, fitnessGoal),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileFieldTile(
            label: 'Activity Level',
            value: activityLevel.label,
            onTap: () => _showActivityLevelPicker(context, activityLevel),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _submitProfile(context),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitProfile(BuildContext context) {
    final profile = widget.data.profile;
    context.read<ProfileBloc>().add(
          UpdateProfile(
            ProfileUpdateRequest(
              name: _nameController.text.trim().isEmpty
                  ? profile.name
                  : _nameController.text.trim(),
              age: profile.age,
              height: profile.height,
              weight: profile.weight,
              gender: ProfileValueParser.gender(profile.gender),
              fitnessGoal: ProfileValueParser.fitnessGoal(profile.fitnessGoal),
              activityLevel:
                  ProfileValueParser.activityLevel(profile.activityLevel),
            ),
          ),
        );
  }

  void _updateProfile(
    BuildContext context, {
    String? name,
    int? age,
    double? height,
    double? weight,
    Gender? gender,
    FitnessGoal? fitnessGoal,
    ActivityLevel? activityLevel,
  }) {
    final profile = widget.data.profile;
    context.read<ProfileBloc>().add(
          UpdateProfile(
            ProfileUpdateRequest(
              name: name ?? _nameController.text.trim(),
              age: age ?? profile.age,
              height: height ?? profile.height,
              weight: weight ?? profile.weight,
              gender: gender ?? ProfileValueParser.gender(profile.gender),
              fitnessGoal: fitnessGoal ??
                  ProfileValueParser.fitnessGoal(profile.fitnessGoal),
              activityLevel: activityLevel ??
                  ProfileValueParser.activityLevel(profile.activityLevel),
            ),
          ),
        );
  }

  Future<void> _showAgePicker(BuildContext context, int currentAge) {
    const minAge = 13;
    const maxAge = 100;
    final ages = List.generate(maxAge - minAge + 1, (index) => '${minAge + index}');
    var selectedAge = currentAge;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ProfileSheet(
          title: 'Age',
          child: OnboardingWheelPicker(
            values: ages,
            selectedIndex: (currentAge - minAge).clamp(0, ages.length - 1),
            unit: 'years',
            onChanged: (index) => selectedAge = minAge + index,
          ),
          onSave: () {
            Navigator.pop(sheetContext);
            _updateProfile(context, age: selectedAge);
          },
        );
      },
    );
  }

  Future<void> _showHeightPicker(BuildContext context, double currentHeight) {
    const minHeight = 100;
    const maxHeight = 250;
    final heights =
        List.generate(maxHeight - minHeight + 1, (index) => '${minHeight + index}');
    var selectedHeight = currentHeight;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ProfileSheet(
          title: 'Height',
          child: OnboardingWheelPicker(
            values: heights,
            selectedIndex:
                (currentHeight.round() - minHeight).clamp(0, heights.length - 1),
            unit: 'cm',
            onChanged: (index) => selectedHeight = (minHeight + index).toDouble(),
          ),
          onSave: () {
            Navigator.pop(sheetContext);
            _updateProfile(context, height: selectedHeight);
          },
        );
      },
    );
  }

  Future<void> _showWeightPicker(BuildContext context, double currentWeight) {
    const minWeight = 30;
    const maxWeight = 200;
    final weights =
        List.generate(maxWeight - minWeight + 1, (index) => '${minWeight + index}');
    var selectedWeight = currentWeight;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ProfileSheet(
          title: 'Weight',
          child: OnboardingWheelPicker(
            values: weights,
            selectedIndex:
                (currentWeight.round() - minWeight).clamp(0, weights.length - 1),
            unit: 'kg',
            onChanged: (index) => selectedWeight = (minWeight + index).toDouble(),
          ),
          onSave: () {
            Navigator.pop(sheetContext);
            _updateProfile(context, weight: selectedWeight);
          },
        );
      },
    );
  }

  Future<void> _showGenderPicker(BuildContext context, Gender currentGender) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ProfileSheet(
          title: 'Gender',
          child: Column(
            children: Gender.values.map((gender) {
              return OnboardingOptionCard(
                title: gender.label,
                isSelected: gender == currentGender,
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (gender != currentGender) {
                    _updateProfile(context, gender: gender);
                  }
                },
                leading: GenderLeadingIcon(
                  icon: gender == Gender.male
                      ? Icons.male_rounded
                      : Icons.female_rounded,
                  isSelected: gender == currentGender,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showFitnessGoalPicker(
    BuildContext context,
    FitnessGoal currentGoal,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ProfileSheet(
          title: 'Fitness Goal',
          child: Column(
            children: FitnessGoal.values.map((goal) {
              return OnboardingOptionCard(
                title: goal.label,
                subtitle: goal.description,
                icon: goal.icon,
                isSelected: goal == currentGoal,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _updateProfile(context, fitnessGoal: goal);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showActivityLevelPicker(
    BuildContext context,
    ActivityLevel currentLevel,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ProfileSheet(
          title: 'Activity Level',
          child: Column(
            children: ActivityLevel.values.map((level) {
              return OnboardingOptionCard(
                title: level.label,
                subtitle: level.description,
                icon: level.icon,
                isSelected: level == currentLevel,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _updateProfile(context, activityLevel: level);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({
    required this.title,
    required this.child,
    this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
          if (onSave != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onSave,
                child: const Text('Save'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
