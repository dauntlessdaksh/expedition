import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/avatar_3d_viewer.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/profile_data.dart';

/// Premium profile header with avatar, name, goal, and streak.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.data,
    super.key,
  });

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    final fitnessGoal =
        ProfileValueParser.fitnessGoal(data.profile.fitnessGoal).label;

    return Container(
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primary.withValues(alpha: 0.1),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppBorderRadius.xl),
            ),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Avatar3DViewer(
                assetPath: Avatar3DViewer.assetForGender(data.profile.gender),
                backgroundColor: AppColorPalette.darkCard,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                Text(
                  data.profile.name,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  fitnessGoal,
                  style: const TextStyle(
                    color: AppColorPalette.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorPalette.primary.withValues(alpha: 0.12),
                    borderRadius: AppBorderRadius.radiusLg,
                    border: Border.all(
                      color: AppColorPalette.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColorPalette.accent,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${data.currentStreak} day streak',
                        style: const TextStyle(
                          color: AppColorPalette.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
