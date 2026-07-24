import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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
              color: AppColorPalette.darkCard.withValues(alpha: 0.94),
              borderRadius: AppBorderRadius.radiusXl,
              border: Border.all(
                color: AppColorPalette.grey700.withValues(alpha: 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MetricRow(
                    label: 'Duration',
                    value: ActivityFormatters.duration(state.duration),
                    emphasized: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Distance',
                          value: ActivityFormatters.distanceKm(
                            state.distanceMeters,
                          ),
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
          style: TextStyle(
            color: AppColorPalette.grey400,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            color: AppColorPalette.white,
            fontSize: emphasized ? 42 : 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColorPalette.darkSurface.withValues(alpha: 0.85),
        borderRadius: AppBorderRadius.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
