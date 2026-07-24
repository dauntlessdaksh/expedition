import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../onboarding/data/models/gender.dart';
import '../../../onboarding/data/models/user_profile.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/domain/models/profile_data.dart';
import '../../../profile/domain/models/profile_models.dart';
import '../../../../core/services/profile_sync_notifier.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../spotify/presentation/widgets/spotify_settings_section.dart';
import '../widgets/liquid_goal_slider.dart';
import '../widgets/settings_group_card.dart';

/// Premium settings screen with liquid goal sliders and grouped pickers.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
          prev.message != curr.message ||
          (prev.data != curr.data &&
              !curr.isSaving &&
              curr.status == ProfileStatus.loaded),
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          context.read<ProfileBloc>().add(const ClearProfileMessage());
        }

        if (state.status == ProfileStatus.loaded && state.data != null) {
          notifyProfileChanged();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.expeditionColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: context.expeditionColors.scaffoldBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: context.expeditionColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: switch (state.status) {
            ProfileStatus.initial ||
            ProfileStatus.loading =>
              const Center(
                child: CircularProgressIndicator(
                  color: AppColorPalette.primary,
                ),
              ),
            ProfileStatus.failure => Center(
                child: TextButton(
                  onPressed: () =>
                      context.read<ProfileBloc>().add(const LoadProfile()),
                  child: const Text('Retry'),
                ),
              ),
            ProfileStatus.loaded when state.data != null => _SettingsBody(
                data: state.data!,
                isSaving: state.isSaving,
              ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.data,
    required this.isSaving,
  });

  final ProfileData data;
  final bool isSaving;

  static final _stepsFormat = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final preferences = data.preferences;
    final profile = data.profile;
    final gender = ProfileValueParser.gender(profile.gender);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            const SettingsSectionLabel('Goals'),
            LiquidGoalSlider(
              icon: Icons.directions_walk_rounded,
              iconColor: const Color(0xFF4ADE80),
              label: 'Daily Steps Goal',
              value: preferences.dailyStepGoal.toDouble(),
              displayValue:
                  '${_stepsFormat.format(preferences.dailyStepGoal)} steps',
              min: 1000,
              max: 30000,
              divisions: 58,
              onChanged: (value) => _updatePreferences(
                context,
                PreferencesUpdateRequest(
                  dailyStepGoal: value.round(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGoalSlider(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFFB923C),
              label: 'Daily Calorie Goal',
              value: preferences.dailyCalorieGoal.toDouble(),
              displayValue: '${preferences.dailyCalorieGoal} kcal',
              min: 100,
              max: 3000,
              divisions: 58,
              onChanged: (value) => _updatePreferences(
                context,
                PreferencesUpdateRequest(
                  dailyCalorieGoal: value.round(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LiquidGoalSlider(
              icon: Icons.route_rounded,
              iconColor: const Color(0xFF60A5FA),
              label: 'Daily Distance Goal',
              value: preferences.dailyDistanceGoalKm,
              displayValue: preferences.usesMetric
                  ? '${preferences.dailyDistanceGoalKm.toStringAsFixed(1)} km'
                  : '${(preferences.dailyDistanceGoalKm * 0.621371).toStringAsFixed(1)} mi',
              min: 1,
              max: 30,
              divisions: 58,
              onChanged: (value) => _updatePreferences(
                context,
                PreferencesUpdateRequest(
                  dailyDistanceGoalKm: value,
                ),
              ),
            ),
            const SettingsSectionHint(
              'Set your daily activity goals. The rings on the home screen show your progress toward these goals.',
            ),
            const SettingsSectionLabel('Units'),
            SettingsGroupCard(
              child: SettingsPickerRow(
                icon: Icons.straighten_rounded,
                iconColor: const Color(0xFF60A5FA),
                label: 'Distance Unit',
                value: preferences.usesMetric ? 'Metric (km)' : 'Imperial (mi)',
                onTap: () => _showUnitPicker(context, preferences.unit),
                showDivider: false,
              ),
            ),
            const SettingsSectionLabel('Appearance'),
            SettingsGroupCard(
              child: SettingsPickerRow(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFFA78BFA),
                label: 'Appearance',
                value: _themeLabel(preferences.theme),
                onTap: () => _showThemePicker(context, preferences.theme),
                showDivider: false,
              ),
            ),
            const SettingsSectionHint(
              'Choose how the app looks. System will follow your device settings.',
            ),
            const SpotifySettingsSection(),
            const SettingsSectionLabel('Gender'),
            SettingsGroupCard(
              child: SettingsPickerRow(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF38BDF8),
                label: 'Gender',
                value: gender.label,
                onTap: () => _showGenderPicker(context, profile, gender),
                showDivider: false,
              ),
            ),
            const SettingsSectionHint(
              'Your avatar will be based on your gender.',
            ),
            Center(
              child: TextButton.icon(
                onPressed: isSaving
                    ? null
                    : () => _updatePreferences(
                          context,
                          const PreferencesUpdateRequest(
                            unit: 'metric',
                            theme: 'system',
                            dailyStepGoal: 10000,
                            dailyCalorieGoal: 600,
                            dailyDistanceGoalKm: 8,
                          ),
                        ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColorPalette.primary,
                  size: 20,
                ),
                label: const Text(
                  'Reset to Defaults',
                  style: TextStyle(
                    color: AppColorPalette.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isSaving)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: AppColorPalette.primary,
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
    );
  }

  String _themeLabel(String theme) => switch (theme) {
        'dark' => 'Dark',
        'light' => 'Light',
        _ => 'System',
      };

  void _updatePreferences(
    BuildContext context,
    PreferencesUpdateRequest request,
  ) {
    context.read<ProfileBloc>().add(UpdatePreferences(request));
  }

  void _showUnitPicker(BuildContext context, String current) {
    _showOptionsSheet(
      context: context,
      title: 'Distance Unit',
      options: const [
        _PickerOption('Metric (km)', 'metric'),
        _PickerOption('Imperial (mi)', 'imperial'),
      ],
      selected: current,
      onSelected: (value) => _updatePreferences(
        context,
        PreferencesUpdateRequest(unit: value),
      ),
    );
  }

  void _showThemePicker(BuildContext context, String current) {
    _showOptionsSheet(
      context: context,
      title: 'Appearance',
      options: const [
        _PickerOption('System', 'system'),
        _PickerOption('Dark', 'dark'),
        _PickerOption('Light', 'light'),
      ],
      selected: current,
      onSelected: (value) {
        final mode = value == 'dark'
            ? ThemeMode.dark
            : value == 'light'
                ? ThemeMode.light
                : ThemeMode.system;
        context.read<ThemeCubit>().setThemeMode(mode);
        _updatePreferences(
          context,
          PreferencesUpdateRequest(theme: value),
        );
      },
    );
  }

  void _showGenderPicker(
    BuildContext context,
    UserProfile profile,
    Gender current,
  ) {
    _showOptionsSheet(
      context: context,
      title: 'Gender',
      options: Gender.values
          .map((g) => _PickerOption(g.label, g.storageValue))
          .toList(),
      selected: current.storageValue,
      onSelected: (value) {
        final gender = ProfileValueParser.gender(value);
        context.read<ProfileBloc>().add(
              UpdateProfile(
                ProfileUpdateRequest(
                  name: profile.name,
                  age: profile.age,
                  height: profile.height,
                  weight: profile.weight,
                  gender: gender,
                  fitnessGoal:
                      ProfileValueParser.fitnessGoal(profile.fitnessGoal),
                  activityLevel:
                      ProfileValueParser.activityLevel(profile.activityLevel),
                ),
              ),
            );
      },
    );
  }

  void _showOptionsSheet({
    required BuildContext context,
    required String title,
    required List<_PickerOption> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = context.expeditionColors;

        return Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...options.map((option) {
                final isSelected = option.value == selected;
                return ListTile(
                  title: Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColorPalette.primary
                          : colors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColorPalette.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (!isSelected) onSelected(option.value);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _PickerOption {
  const _PickerOption(this.label, this.value);

  final String label;
  final String value;
}
