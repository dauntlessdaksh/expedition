import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Counts up a numeric value when the analytics screen loads.
class AnalyticsAnimatedValue extends StatelessWidget {
  const AnalyticsAnimatedValue({
    required this.value,
    required this.formatter,
    this.style,
    super.key,
  });

  final num value;
  final String Function(num animatedValue) formatter;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          formatter(animatedValue),
          style: style,
        );
      },
    );
  }
}

/// Premium summary tile for top-level analytics totals.
class AnalyticsSummaryTile extends StatelessWidget {
  const AnalyticsSummaryTile({
    required this.label,
    required this.value,
    required this.formatter,
    super.key,
  });

  final String label;
  final num value;
  final String Function(num animatedValue) formatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmerFor(context),
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: colors.cardElevated.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnalyticsAnimatedValue(
            value: value,
            formatter: formatter,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
