import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/avatar_lifecycle.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/avatar_3d_viewer.dart';
import '../../domain/models/gamification_models.dart';

/// Full-screen celebration shown when an achievement is unlocked.
class AchievementCelebrationDialog extends StatefulWidget {
  const AchievementCelebrationDialog({
    required this.achievement,
    required this.gender,
    super.key,
  });

  final Achievement achievement;
  final String gender;

  static Future<void> show(
    BuildContext context, {
    required Achievement achievement,
    required String gender,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColorPalette.black.withValues(alpha: 0.82),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AchievementCelebrationDialog(
          achievement: achievement,
          gender: gender,
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AchievementCelebrationDialog> createState() =>
      _AchievementCelebrationDialogState();
}

class _AchievementCelebrationDialogState
    extends State<AchievementCelebrationDialog> {
  static const _avatarOwner = 'celebration';

  @override
  void initState() {
    super.initState();
    AvatarLifecycle.acquire(_avatarOwner);
  }

  @override
  void dispose() {
    AvatarLifecycle.release(_avatarOwner);
    super.dispose();
  }

  String get _dancingAsset {
    return widget.gender.toLowerCase() == 'female'
        ? AppAssets.femaleDancingGlb
        : AppAssets.maleDancingGlb;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: PremiumGradients.cardShimmer,
                borderRadius: AppBorderRadius.radiusXl,
                border: Border.all(
                  color: AppColorPalette.primary.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColorPalette.primary.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Achievement unlocked!',
                    style: TextStyle(
                      color: AppColorPalette.primaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: AppBorderRadius.radiusLg,
                      child: Avatar3DViewer(
                        assetPath: _dancingAsset,
                        backgroundColor: AppColorPalette.darkCard,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.achievement.icon,
                    style: const TextStyle(fontSize: 42),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.achievement.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColorPalette.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.achievement.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColorPalette.grey400,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
