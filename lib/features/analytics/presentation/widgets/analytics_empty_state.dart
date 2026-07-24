import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Empty state shown when no workouts exist for analytics.
class AnalyticsEmptyState extends StatelessWidget {
  const AnalyticsEmptyState({
    required this.onStartActivity,
    super.key,
  });

  final VoidCallback onStartActivity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorPalette.primary.withValues(alpha: 0.24),
                    AppColorPalette.darkCard,
                  ],
                ),
                border: Border.all(
                  color: AppColorPalette.primary.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColorPalette.primary.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColorPalette.primaryLight,
                size: 58,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Complete your first workout to unlock analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColorPalette.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Track an activity and your trends, records, and insights will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColorPalette.grey500,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: PremiumGradients.accentButton,
                borderRadius: AppBorderRadius.radiusLg,
                boxShadow: [
                  BoxShadow(
                    color: AppColorPalette.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onStartActivity,
                  borderRadius: AppBorderRadius.radiusLg,
                  child: const Center(
                    child: Text(
                      'Start Activity',
                      style: TextStyle(
                        color: AppColorPalette.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
