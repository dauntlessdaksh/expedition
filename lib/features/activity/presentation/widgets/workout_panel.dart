import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/activity_bloc.dart';
import '../utils/activity_formatters.dart';

/// Floating panel showing live workout metrics.
class WorkoutPanel extends StatelessWidget {
  const WorkoutPanel({
    required this.state,
    super.key,
  });

  final ActivityState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      offset: state.showWorkoutPanel ? Offset.zero : const Offset(0, 0.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: state.showWorkoutPanel ? 1 : 0,
        child: IgnorePointer(
          ignoring: !state.showWorkoutPanel,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColorPalette.glassOverlay,
              borderRadius: AppBorderRadius.radiusXxl,
              border: Border.all(color: AppColorPalette.divider),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.black.withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MetricRow(
                    label: 'Duration',
                    value: ActivityFormatters.duration(state.duration),
                    emphasized: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Distance',
                          value: ActivityFormatters.distanceKm(
                            state.distanceMeters,
                          ),
                          highlight: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _MetricTile(
                          label: 'Current Speed',
                          value: ActivityFormatters.speedKmh(
                            state.currentSpeedMps,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Average Speed',
                          value: ActivityFormatters.speedKmh(
                            state.averageSpeedMps,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _MetricTile(
                          label: 'GPS Accuracy',
                          value: ActivityFormatters.gpsAccuracy(
                            state.gpsAccuracyMeters,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.statLabel,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: emphasized
              ? AppTypography.statLarge.copyWith(fontSize: 48)
              : AppTypography.statMedium,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColorPalette.surface,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: highlight
              ? AppColorPalette.primary.withValues(alpha: 0.3)
              : AppColorPalette.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.statLabel.copyWith(fontSize: 10),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.statMedium.copyWith(
              fontSize: 20,
              color: highlight
                  ? AppColorPalette.primary
                  : AppColorPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
