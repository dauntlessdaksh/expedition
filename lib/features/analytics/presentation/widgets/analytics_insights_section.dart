import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/theme/premium_gradients.dart';
import 'analytics_section_card.dart';

/// Generated insights based on workout patterns.
class AnalyticsInsightsSection extends StatelessWidget {
  const AnalyticsInsightsSection({
    required this.insights,
    super.key,
  });

  final List<String> insights;

  @override
  Widget build(BuildContext context) {
    return AnalyticsSectionCard(
      title: 'Insights',
      subtitle: 'Patterns from your training history',
      child: Column(
        children: insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _InsightTile(text: insight),
          );
        }).toList(),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmerFor(context),
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColorPalette.primary.withValues(alpha: 0.15),
              borderRadius: AppBorderRadius.radiusMd,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColorPalette.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
