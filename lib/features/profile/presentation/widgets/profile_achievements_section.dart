import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/models/profile_data.dart';
import 'profile_section_card.dart';

/// Earned and locked achievement badges with link to the full rewards hub.
class ProfileAchievementsSection extends StatelessWidget {
  const ProfileAchievementsSection({
    required this.achievements,
    super.key,
  });

  final List<AchievementBadge> achievements;

  static const _previewCount = 4;

  @override
  Widget build(BuildContext context) {
    final preview = achievements.take(_previewCount).toList();
    final unlockedCount = achievements.where((item) => item.isEarned).length;

    return ProfileSectionCard(
      title: 'Achievements',
      subtitle:
          '$unlockedCount of ${achievements.length} badges earned on your journey',
      action: TextButton(
        onPressed: () => context.push(RouteConstants.gamificationPath),
        child: const Text('View all'),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: preview.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final badge = preview[index];
          return _AchievementBadgeCard(badge: badge);
        },
      ),
    );
  }
}

class _AchievementBadgeCard extends StatelessWidget {
  const _AchievementBadgeCard({required this.badge});

  final AchievementBadge badge;

  @override
  Widget build(BuildContext context) {
    final earned = badge.isEarned;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: earned ? 1 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: earned
              ? AppColorPalette.primary.withValues(alpha: 0.1)
              : AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
          borderRadius: AppBorderRadius.radiusLg,
          border: Border.all(
            color: earned
                ? AppColorPalette.primary.withValues(alpha: 0.35)
                : AppColorPalette.grey700.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              earned ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
              color: earned
                  ? AppColorPalette.primaryLight
                  : AppColorPalette.grey500,
            ),
            const Spacer(),
            Text(
              badge.title,
              style: const TextStyle(
                color: AppColorPalette.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              badge.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColorPalette.grey500,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
