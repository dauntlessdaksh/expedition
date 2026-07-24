import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../domain/models/analytics_records.dart';
import 'analytics_section_card.dart';

/// Grid of personal record cards derived from workout history.
class AnalyticsPersonalRecords extends StatelessWidget {
  const AnalyticsPersonalRecords({
    required this.records,
    super.key,
  });

  final PersonalRecords records;

  @override
  Widget build(BuildContext context) {
    final items = [
      records.longestWorkout,
      records.longestDistance,
      records.fastestAverageSpeed,
      records.highestCalories,
      records.longestDuration,
    ];

    return AnalyticsSectionCard(
      title: 'Personal Records',
      subtitle: 'Your all-time bests',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          return _RecordCard(record: items[index]);
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            record.value,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (record.subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              record.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColorPalette.grey500,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
