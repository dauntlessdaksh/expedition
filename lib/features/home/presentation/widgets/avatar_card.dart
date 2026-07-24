import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/avatar_3d_viewer.dart';

/// Hero card displaying the user's animated 3D avatar and daily mission.
class AvatarCard extends StatelessWidget {
  const AvatarCard({
    required this.gender,
    this.showAvatar = true,
    super.key,
  });

  final String gender;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final avatarHeight = MediaQuery.sizeOf(context).height * 0.28;
    final clampedHeight = avatarHeight.clamp(200.0, 280.0);

    return Container(
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColorPalette.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
              height: clampedHeight,
              width: double.infinity,
              child: showAvatar
                  ? Avatar3DViewer(
                      assetPath: Avatar3DViewer.assetForGender(gender),
                      backgroundColor: AppColorPalette.darkCard,
                    )
                  : const _AvatarPlaceholder(),
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
                  "Today's Mission",
                  style: TextStyle(
                    color: AppColorPalette.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Keep moving. Every step counts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColorPalette.darkCard,
            AppColorPalette.darkCard.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_run_rounded,
          color: AppColorPalette.primary,
          size: 72,
        ),
      ),
    );
  }
}
