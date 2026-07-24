import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../domain/models/profile_models.dart';
import '../bloc/profile_bloc.dart';
import 'profile_section_card.dart';

/// Units, theme, and notification preferences.
class ProfilePreferencesSection extends StatelessWidget {
  const ProfilePreferencesSection({
    required this.preferences,
    required this.onThemeChanged,
    super.key,
  });

  final UserPreferences preferences;
  final ValueChanged<String> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return ProfileSectionCard(
      title: 'Preferences',
      subtitle: 'Customize how Expedition looks and feels',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Units',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileChoiceRow(
            options: const [
              ProfileChoiceOption(label: 'Kilometers', value: 'metric'),
              ProfileChoiceOption(label: 'Miles', value: 'imperial'),
            ],
            selectedValue: preferences.unit,
            onChanged: (value) => context.read<ProfileBloc>().add(
                  UpdatePreferences(PreferencesUpdateRequest(unit: value)),
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Theme',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileChoiceRow(
            options: const [
              ProfileChoiceOption(label: 'Light', value: 'light'),
              ProfileChoiceOption(label: 'Dark', value: 'dark'),
              ProfileChoiceOption(label: 'System', value: 'system'),
            ],
            selectedValue: preferences.theme,
            onChanged: (value) {
              onThemeChanged(value);
              context.read<ProfileBloc>().add(
                    UpdatePreferences(PreferencesUpdateRequest(theme: value)),
                  );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.cardElevated.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: colors.divider,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Workout reminders and achievements',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: preferences.notificationsEnabled,
                  activeThumbColor: AppColorPalette.primary,
                  onChanged: (value) => context.read<ProfileBloc>().add(
                        UpdatePreferences(
                          PreferencesUpdateRequest(
                            notificationsEnabled: value,
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
