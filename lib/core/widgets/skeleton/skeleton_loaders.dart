import 'package:flutter/material.dart';

import '../../constants/app_border_radius.dart';
import '../../constants/app_spacing.dart';
import 'skeleton_shimmer.dart';

/// Reusable skeleton layouts for primary Expedition screens.
abstract final class SkeletonLoaders {
  static Widget dashboard() {
    return const ColoredBox(
      color: Colors.black,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 90, height: 16),
            SizedBox(height: AppSpacing.lg),
            SkeletonBox(
              width: double.infinity,
              height: 160,
            ),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(width: 160, height: 16),
            SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 52, child: SkeletonBox(height: 320)),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 48,
                  child: Column(
                    children: [
                      SkeletonBox(
                        width: 148,
                        height: 148,
                        borderRadius: AppBorderRadius.radiusFull,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      SkeletonBox(width: double.infinity, height: 180),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget history() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const SkeletonBox(
        width: double.infinity,
        height: 118,
        borderRadius: AppBorderRadius.radiusXl,
      ),
    );
  }

  static Widget analytics() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 160, height: 30),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(width: 240, height: 14),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox(width: 160, height: 16),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(
            width: double.infinity,
            height: 10,
            borderRadius: AppBorderRadius.radiusFull,
          ),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: SkeletonBox(
                width: double.infinity,
                height: index.isEven ? 160 : 220,
                borderRadius: AppBorderRadius.radiusXl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget profile() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: SkeletonBox(
              width: double.infinity,
              height: index == 0 ? 220 : 160,
              borderRadius: AppBorderRadius.radiusXl,
            ),
          ),
        ),
      ),
    );
  }

  static Widget gamification() {
    return analytics();
  }

  static Widget activityMapOverlay({String message = 'Initializing GPS...'}) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 220,
              child: SkeletonBox(
                height: 14,
                borderRadius: AppBorderRadius.radiusFull,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget workoutDetail() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: double.infinity,
            height: 220,
            borderRadius: AppBorderRadius.radiusXl,
          ),
          SizedBox(height: AppSpacing.xl),
          SkeletonBox(width: 180, height: 24),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: double.infinity, height: 120),
        ],
      ),
    );
  }
}
