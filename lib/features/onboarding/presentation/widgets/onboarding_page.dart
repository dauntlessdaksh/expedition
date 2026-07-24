import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Data model for a single onboarding page.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}

/// Static content for the three onboarding pages.
abstract final class OnboardingContent {
  static const pages = [
    OnboardingPageData(
      title: 'Track Every Journey',
      subtitle: 'Record every walk, run and ride with precision.',
      icon: Icons.route_rounded,
      accentColor: AppColorPalette.primary,
    ),
    OnboardingPageData(
      title: 'Offline First',
      subtitle: 'Your activities are always stored locally.',
      icon: Icons.cloud_off_rounded,
      accentColor: AppColorPalette.info,
    ),
    OnboardingPageData(
      title: 'Reach Your Goals',
      subtitle: 'Stay motivated with progress and analytics.',
      icon: Icons.emoji_events_rounded,
      accentColor: AppColorPalette.accent,
    ),
  ];
}

/// Illustration placeholder for onboarding pages.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    required this.icon,
    required this.accentColor,
    super.key,
  });

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accentColor.withValues(alpha: 0.25),
            accentColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: PremiumGradients.cardShimmer,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 56,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

/// Single page content within the onboarding PageView.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.data,
    super.key,
  });

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OnboardingIllustration(
            icon: data.icon,
            accentColor: data.accentColor,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 17,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
