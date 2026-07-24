import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/home_dashboard_data.dart';

/// Minimal weekly activity bar chart.
class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    required this.weeklyActivity,
    super.key,
  });

  final List<WeeklyActivityDay> weeklyActivity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Activity',
          style: TextStyle(
            color: AppColorPalette.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyActivity.map((day) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: day.value),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) {
                      final isActive = day.value > 0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor:
                                    animatedValue.clamp(0.04, 1.0),
                                widthFactor: 0.72,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColorPalette.primary
                                        : AppColorPalette.grey800,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            day.label,
                            style: TextStyle(
                              color: AppColorPalette.textSecondary
                                  .withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
