import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/goal.dart';
import 'gamification_section_card.dart';

/// Active weekly challenges with live progress.
class GamificationChallengeSection extends StatelessWidget {
  const GamificationChallengeSection({
    required this.challenges,
    super.key,
  });

  final List<Challenge> challenges;

  @override
  Widget build(BuildContext context) {
    return GamificationSectionCard(
      title: 'Challenges',
      subtitle: 'Weekly missions to keep you moving',
      child: Column(
        children: challenges.map((challenge) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ChallengeCard(challenge: challenge),
          );
        }).toList(),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: challenge.isCompleted
            ? AppColorPalette.primary.withValues(alpha: 0.1)
            : AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
        borderRadius: AppBorderRadius.radiusLg,
        border: Border.all(
          color: challenge.isCompleted
              ? AppColorPalette.primary.withValues(alpha: 0.35)
              : AppColorPalette.grey700.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (challenge.isCompleted)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColorPalette.primaryLight,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            challenge.description,
            style: const TextStyle(
              color: AppColorPalette.grey500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GamificationProgressBar(progress: challenge.progress),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${challenge.progressPercent}% complete',
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
