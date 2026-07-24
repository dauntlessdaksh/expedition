import 'package:flutter/material.dart';

import '../constants/app_border_radius.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../services/haptic_service.dart';
import '../theme/premium_gradients.dart';

/// Premium empty state with icon, copy, and optional CTA.
class PremiumEmptyState extends StatelessWidget {
  const PremiumEmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;

  factory PremiumEmptyState.noWorkouts({required VoidCallback onStartActivity}) {
    return PremiumEmptyState(
      icon: Icons.route_rounded,
      title: 'No workouts yet',
      description:
          'Start your first activity to begin building your fitness journey.',
      actionLabel: 'Start First Activity',
      onAction: onStartActivity,
      semanticLabel: 'No workouts recorded yet',
    );
  }

  factory PremiumEmptyState.noAnalytics({required VoidCallback onStartActivity}) {
    return PremiumEmptyState(
      icon: Icons.insights_rounded,
      title: 'Analytics unlock after your first workout',
      description:
          'Track an activity and your trends, records, and insights will appear here.',
      actionLabel: 'Start Activity',
      onAction: onStartActivity,
      semanticLabel: 'No analytics data available',
    );
  }

  factory PremiumEmptyState.noAchievements({required VoidCallback onStartActivity}) {
    return PremiumEmptyState(
      icon: Icons.emoji_events_outlined,
      title: 'No achievements yet',
      description:
          'Complete workouts to earn badges and unlock celebration rewards.',
      actionLabel: 'Start Activity',
      onAction: onStartActivity,
      semanticLabel: 'No achievements earned yet',
    );
  }

  factory PremiumEmptyState.noGoals() {
    return const PremiumEmptyState(
      icon: Icons.flag_outlined,
      title: 'Goals will appear here',
      description:
          'Your daily and weekly goals update automatically from workout data.',
    );
  }

  factory PremiumEmptyState.noSearchResults({required VoidCallback onClearSearch}) {
    return PremiumEmptyState(
      icon: Icons.search_off_rounded,
      title: 'No matching workouts',
      description:
          'Try a different search term or clear filters to see all activities.',
      actionLabel: 'Clear Search',
      onAction: onClearSearch,
      semanticLabel: 'No search results found',
    );
  }

  factory PremiumEmptyState.filteredEmpty({required VoidCallback onClearFilters}) {
    return PremiumEmptyState(
      icon: Icons.filter_alt_off_rounded,
      title: 'No workouts match your filters',
      description: 'Adjust your date filter or search to find saved activities.',
      actionLabel: 'Clear Filters',
      onAction: onClearFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? title,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorPalette.primary.withValues(alpha: 0.22),
                      AppColorPalette.darkCard,
                    ],
                  ),
                  border: Border.all(
                    color: AppColorPalette.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColorPalette.primaryLight,
                  size: 52,
                  semanticLabel: '',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColorPalette.grey500,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: PremiumGradients.accentButton,
                      borderRadius: AppBorderRadius.radiusLg,
                      boxShadow: [
                        BoxShadow(
                          color: AppColorPalette.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticService.lightImpact();
                          onAction!();
                        },
                        borderRadius: AppBorderRadius.radiusLg,
                        child: Center(
                          child: Text(
                            actionLabel!,
                            style: const TextStyle(
                              color: AppColorPalette.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
