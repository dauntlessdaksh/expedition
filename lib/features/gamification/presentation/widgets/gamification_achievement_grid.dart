import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/navigation/main_tab.dart';
import '../../../../core/widgets/premium_empty_state.dart';
import '../../domain/models/gamification_models.dart';
import 'gamification_section_card.dart';

/// Grid of achievements with progress and unlock state.
class GamificationAchievementGrid extends StatelessWidget {
  const GamificationAchievementGrid({
    required this.achievements,
    super.key,
  });

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    return GamificationSectionCard(
      title: 'Achievements',
      subtitle: 'Earn badges by hitting fitness milestones',
      child: achievements.isEmpty
          ? PremiumEmptyState.noAchievements(
              onStartActivity: () =>
                  MainNavigation.goToTab(context, MainTab.activity),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                return _AchievementCard(achievement: achievements[index]);
              },
            ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: unlocked ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColorPalette.primary.withValues(alpha: 0.12)
              : AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
          borderRadius: AppBorderRadius.radiusLg,
          border: Border.all(
            color: unlocked
                ? AppColorPalette.primary.withValues(alpha: 0.35)
                : AppColorPalette.grey700.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(
              achievement.title,
              style: const TextStyle(
                color: AppColorPalette.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              achievement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColorPalette.grey500,
                fontSize: 11,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GamificationProgressBar(progress: achievement.progress, height: 6),
            const SizedBox(height: AppSpacing.xs),
            Text(
              unlocked ? 'Unlocked' : '${achievement.progressPercent}%',
              style: TextStyle(
                color: unlocked
                    ? AppColorPalette.primaryLight
                    : AppColorPalette.grey400,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
