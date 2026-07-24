import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Shared scaffold for onboarding steps with progress and navigation.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    required this.body,
    required this.onContinue,
    super.key,
    this.title,
    this.subtitle,
    this.onBack,
    this.showProgress = true,
    this.progress,
    this.continueLabel = 'Continue',
    this.isLoading = false,
    this.validationError,
    this.showBackButton = true,
  });

  final Widget body;
  final VoidCallback onContinue;
  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showProgress;
  final double? progress;
  final String continueLabel;
  final bool isLoading;
  final String? validationError;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPalette.darkBackground,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: PremiumGradients.darkBackground,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            if (showBackButton && onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColorPalette.grey300,
                    size: 20,
                  ),
                ),
              )
            else
              const SizedBox(height: AppSpacing.xxl),

            if (showProgress && progress != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: OnboardingProgressBar(progress: progress!),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      OnboardingTitle(title: title!, subtitle: subtitle),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                    body,
                  ],
                ),
              ),
            ),

            if (validationError != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: Text(
                  validationError!,
                  style: const TextStyle(
                    color: AppColorPalette.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: GradientButton(
                label: continueLabel,
                onPressed: onContinue,
                isLoading: isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

/// Animated linear progress indicator for onboarding steps.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: AppColorPalette.darkCardElevated,
            color: AppColorPalette.primary,
          );
        },
      ),
    );
  }
}

/// Large title and optional subtitle for onboarding steps.
class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle({
    required this.title,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColorPalette.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.15,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
