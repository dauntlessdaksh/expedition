import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/voice/voice_settings.dart';
import '../../data/models/activity_preferences.dart';
import '../../data/models/activity_type.dart';
import 'activity_premium_controls.dart';

/// Bottom sheet for choosing the current activity type.
class ActivitySelectionSheet extends StatelessWidget {
  const ActivitySelectionSheet({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ActivityType selected;
  final ValueChanged<ActivityType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Choose Activity',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColorPalette.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          decoration: BoxDecoration(
            color: AppColorPalette.darkCardElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Builder(
            builder: (context) {
              final types = ActivityType.values
                  .where(
                    (type) =>
                        type == ActivityType.walk ||
                        type == ActivityType.run ||
                        type == ActivityType.hike,
                  )
                  .toList();

              return Column(
                children: List.generate(types.length, (index) {
                  final type = types[index];
                  final isSelected = type == selected;
                  final isFirst = index == 0;
                  final isLast = index == types.length - 1;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onSelected(type);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.vertical(
                        top: isFirst ? const Radius.circular(20) : Radius.zero,
                        bottom: isLast ? const Radius.circular(20) : Radius.zero,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                    color: AppColorPalette.darkCardElevated
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                        ),
                        child: Row(
                          children: [
                            Text(type.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                type.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColorPalette.white
                                      : AppColorPalette.grey300,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            AnimatedScale(
                              scale: isSelected ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: AppColorPalette.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColorPalette.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for activity-specific settings.
class ActivitySettingsSheet extends StatefulWidget {
  const ActivitySettingsSheet({
    required this.preferences,
    required this.onSave,
    required this.voiceSettings,
    required this.onVoiceSettingsChanged,
    super.key,
  });

  final ActivityPreferences preferences;
  final ValueChanged<ActivityPreferences> onSave;
  final VoiceSettings voiceSettings;
  final ValueChanged<VoiceSettings> onVoiceSettingsChanged;

  @override
  State<ActivitySettingsSheet> createState() => _ActivitySettingsSheetState();
}

class _ActivitySettingsSheetState extends State<ActivitySettingsSheet> {
  late ActivityPreferences _prefs;
  late VoiceSettings _voiceSettings;

  @override
  void initState() {
    super.initState();
    _prefs = widget.preferences;
    _voiceSettings = widget.voiceSettings;
  }

  @override
  void didUpdateWidget(ActivitySettingsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.voiceSettings != oldWidget.voiceSettings) {
      _voiceSettings = widget.voiceSettings;
    }
  }

  void _update(ActivityPreferences next) {
    setState(() => _prefs = next);
    widget.onSave(next);
  }

  void _updateVoiceSettings(VoiceSettings next) {
    setState(() => _voiceSettings = next);
    widget.onVoiceSettingsChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel('Start Options'),
        _SettingsCard(
          children: [
            _ToggleRow(
              icon: Icons.timer_outlined,
              iconColor: const Color(0xFFFB923C),
              label: 'Countdown',
              value: _prefs.countdownEnabled,
              onChanged: (v) => _update(_prefs.copyWith(countdownEnabled: v)),
            ),
            if (_prefs.countdownEnabled) ...[
              const SizedBox(height: AppSpacing.md),
              _SegmentedSelector(
                options: const [3, 5, 10],
                selected: _prefs.countdownSeconds,
                formatter: (v) => '${v}s',
                onChanged: (v) => _update(_prefs.copyWith(countdownSeconds: v)),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionLabel('Goals'),
        _SettingsCard(
          children: [
            _StepperRow(
              icon: Icons.route_rounded,
              iconColor: const Color(0xFF60A5FA),
              label: 'Distance',
              value: '${_prefs.distanceGoalKm.toStringAsFixed(1)} km',
              onDecrement: _prefs.distanceGoalKm > 1
                  ? () => _update(_prefs.copyWith(
                        distanceGoalKm: (_prefs.distanceGoalKm - 0.5)
                            .clamp(1, 100),
                      ))
                  : null,
              onIncrement: () => _update(_prefs.copyWith(
                distanceGoalKm: (_prefs.distanceGoalKm + 0.5).clamp(1, 100),
              )),
            ),
            Divider(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
              height: AppSpacing.xl,
            ),
            _StepperRow(
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFFA78BFA),
              label: 'Time',
              value: '${_prefs.timeGoalMinutes} min',
              onDecrement: _prefs.timeGoalMinutes > 5
                  ? () => _update(_prefs.copyWith(
                        timeGoalMinutes: _prefs.timeGoalMinutes - 5,
                      ))
                  : null,
              onIncrement: () => _update(_prefs.copyWith(
                timeGoalMinutes: (_prefs.timeGoalMinutes + 5).clamp(5, 180),
              )),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            'Goals are used to calculate your overall progress ring.',
            style: TextStyle(color: AppColorPalette.grey500, fontSize: 13),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionLabel('Tracking'),
        _SettingsCard(
          children: [
            _ToggleRow(
              icon: Icons.pause_circle_outline_rounded,
              iconColor: AppColorPalette.primaryLight,
              label: 'Auto Pause',
              value: _prefs.autoPause,
              onChanged: (v) => _update(_prefs.copyWith(autoPause: v)),
            ),
            Divider(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
              height: AppSpacing.xl,
            ),
            _ToggleRow(
              icon: Icons.vibration_rounded,
              iconColor: const Color(0xFFFB923C),
              label: 'Vibration',
              value: _prefs.vibration,
              onChanged: (v) => _update(_prefs.copyWith(vibration: v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionLabel('Voice Guidance'),
        _VoiceGuidanceSection(
          settings: _voiceSettings,
          onChanged: _updateVoiceSettings,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColorPalette.grey500,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColorPalette.primary.withValues(alpha: 0.45),
          activeThumbColor: AppColorPalette.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onIncrement,
    this.onDecrement,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            '$label  $value',
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _StepperButton(icon: Icons.remove, onTap: onDecrement),
        Container(
          width: 1,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: AppColorPalette.darkCardElevated,
        ),
        _StepperButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onTap != null
                ? AppColorPalette.primary
                : AppColorPalette.grey600,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SegmentedSelector extends StatelessWidget {
  const _SegmentedSelector({
    required this.options,
    required this.selected,
    required this.formatter,
    required this.onChanged,
  });

  final List<int> options;
  final int selected;
  final String Function(int) formatter;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColorPalette.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  formatter(option),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? AppColorPalette.black
                        : AppColorPalette.grey400,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VoiceGuidanceSection extends StatelessWidget {
  const _VoiceGuidanceSection({
    required this.settings,
    required this.onChanged,
  });

  final VoiceSettings settings;
  final ValueChanged<VoiceSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        _ToggleRow(
          icon: Icons.record_voice_over_outlined,
          iconColor: const Color(0xFF4ADE80),
          label: 'Enable Voice Guidance',
          value: settings.enabled,
          onChanged: (value) => onChanged(settings.copyWith(enabled: value)),
        ),
        Divider(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
          height: AppSpacing.xl,
        ),
        const _SettingsSubLabel('Announcement Distance'),
        const SizedBox(height: AppSpacing.sm),
        _EnumSegmentedSelector<VoiceAnnouncementDistance>(
          values: VoiceAnnouncementDistance.values,
          selected: settings.announcementDistance,
          labelBuilder: (value) => value.label,
          onChanged: (value) =>
              onChanged(settings.copyWith(announcementDistance: value)),
        ),
        Divider(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
          height: AppSpacing.xl,
        ),
        const _SettingsSubLabel('Announcement Interval'),
        const SizedBox(height: AppSpacing.sm),
        _EnumSegmentedSelector<VoiceTimeInterval>(
          values: VoiceTimeInterval.values,
          selected: settings.timeInterval,
          labelBuilder: (value) => value.label,
          onChanged: (value) =>
              onChanged(settings.copyWith(timeInterval: value)),
        ),
        Divider(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
          height: AppSpacing.xl,
        ),
        const _SettingsSubLabel('Announcement Content'),
        const SizedBox(height: AppSpacing.sm),
        _ToggleRow(
          icon: Icons.route_rounded,
          iconColor: const Color(0xFF60A5FA),
          label: 'Distance',
          value: settings.content.distance,
          onChanged: (value) => onChanged(
            settings.copyWith(content: settings.content.copyWith(distance: value)),
          ),
        ),
        _ToggleRow(
          icon: Icons.speed_rounded,
          iconColor: const Color(0xFFFB923C),
          label: 'Pace',
          value: settings.content.pace,
          onChanged: (value) => onChanged(
            settings.copyWith(content: settings.content.copyWith(pace: value)),
          ),
        ),
        _ToggleRow(
          icon: Icons.directions_run_rounded,
          iconColor: const Color(0xFFA78BFA),
          label: 'Speed',
          value: settings.content.speed,
          onChanged: (value) => onChanged(
            settings.copyWith(content: settings.content.copyWith(speed: value)),
          ),
        ),
        _ToggleRow(
          icon: Icons.local_fire_department_outlined,
          iconColor: AppColorPalette.primaryLight,
          label: 'Calories',
          value: settings.content.calories,
          onChanged: (value) => onChanged(
            settings.copyWith(
              content: settings.content.copyWith(calories: value),
            ),
          ),
        ),
        _ToggleRow(
          icon: Icons.terrain_rounded,
          iconColor: const Color(0xFF4ADE80),
          label: 'Elevation',
          value: settings.content.elevation,
          onChanged: (value) => onChanged(
            settings.copyWith(
              content: settings.content.copyWith(elevation: value),
            ),
          ),
        ),
        _ToggleRow(
          icon: Icons.gps_fixed_rounded,
          iconColor: AppColorPalette.grey400,
          label: 'GPS Status',
          value: settings.content.gpsStatus,
          onChanged: (value) => onChanged(
            settings.copyWith(
              content: settings.content.copyWith(gpsStatus: value),
            ),
          ),
        ),
        Divider(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
          height: AppSpacing.xl,
        ),
        const _SettingsSubLabel('Speaking Rate'),
        const SizedBox(height: AppSpacing.sm),
        _EnumSegmentedSelector<VoiceSpeakingRate>(
          values: VoiceSpeakingRate.values,
          selected: settings.speakingRate,
          labelBuilder: (value) => value.label,
          onChanged: (value) =>
              onChanged(settings.copyWith(speakingRate: value)),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Uses your device\'s built-in offline voice. Music volume is ducked automatically while speaking.',
          style: TextStyle(color: AppColorPalette.grey500, fontSize: 12),
        ),
      ],
    );
  }
}

class _SettingsSubLabel extends StatelessWidget {
  const _SettingsSubLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColorPalette.grey400,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EnumSegmentedSelector<T> extends StatelessWidget {
  const _EnumSegmentedSelector({
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: values.map((value) {
          final isSelected = value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColorPalette.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labelBuilder(value),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? AppColorPalette.black
                        : AppColorPalette.grey400,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Future<void> showActivitySelectionSheet({
  required BuildContext context,
  required ActivityType selected,
  required ValueChanged<ActivityType> onSelected,
}) {
  return showActivityBottomSheet<void>(
    context: context,
    child: ActivitySelectionSheet(
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

Future<void> showActivitySettingsSheet({
  required BuildContext context,
  required ActivityPreferences preferences,
  required ValueChanged<ActivityPreferences> onSave,
  required VoiceSettings voiceSettings,
  required ValueChanged<VoiceSettings> onVoiceSettingsChanged,
}) {
  return showActivityBottomSheet<void>(
    context: context,
    child: ActivitySettingsSheet(
      preferences: preferences,
      onSave: onSave,
      voiceSettings: voiceSettings,
      onVoiceSettingsChanged: onVoiceSettingsChanged,
    ),
  );
}
