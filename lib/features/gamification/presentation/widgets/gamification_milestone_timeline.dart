import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/gamification_models.dart';
import 'gamification_section_card.dart';

/// Distance milestone timeline.
class GamificationMilestoneTimeline extends StatelessWidget {
  const GamificationMilestoneTimeline({
    required this.milestones,
    super.key,
  });

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    return GamificationSectionCard(
      title: 'Milestones',
      subtitle: 'Total distance milestones on your journey',
      child: Column(
        children: milestones.map((milestone) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _MilestoneRow(milestone: milestone),
          );
        }).toList(),
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.milestone});

  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: milestone.isReached
                ? AppColorPalette.primary.withValues(alpha: 0.2)
                : AppColorPalette.darkCardElevated,
            border: Border.all(
              color: milestone.isReached
                  ? AppColorPalette.primary
                  : AppColorPalette.grey700.withValues(alpha: 0.4),
            ),
          ),
          child: Icon(
            milestone.isReached
                ? Icons.flag_rounded
                : Icons.flag_outlined,
            color: milestone.isReached
                ? AppColorPalette.primaryLight
                : AppColorPalette.grey500,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${milestone.distanceKm.toStringAsFixed(0)} km',
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GamificationProgressBar(progress: milestone.progress, height: 6),
            ],
          ),
        ),
      ],
    );
  }
}
