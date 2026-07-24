import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/navigation/main_tab.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/premium_empty_state.dart';
import '../../../../core/widgets/skeleton/skeleton_loaders.dart';
import '../../../home/presentation/widgets/home_animated_section.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/analytics_activity_pie_chart.dart';
import '../widgets/analytics_goal_progress.dart';
import '../widgets/analytics_insights_section.dart';
import '../widgets/analytics_monthly_trend_chart.dart';
import '../widgets/analytics_personal_records.dart';
import '../widgets/analytics_streak_section.dart';
import '../widgets/analytics_summary_cards.dart';
import '../widgets/analytics_weekly_chart.dart';

/// Premium analytics dashboard powered by persisted workout data.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPalette.darkBackground,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: PremiumGradients.darkBackground,
        ),
        child: SafeArea(
          child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              return switch (state.status) {
                AnalyticsStatus.initial ||
                AnalyticsStatus.loading =>
                  SkeletonLoaders.analytics(),
                AnalyticsStatus.failure => AppErrorView.fromError(
                    StateError('Unable to load analytics'),
                    onRetry: () => context
                        .read<AnalyticsBloc>()
                        .add(const LoadAnalytics()),
                  ),
                AnalyticsStatus.empty => PremiumEmptyState.noAnalytics(
                    onStartActivity: () =>
                        MainNavigation.goToTab(context, MainTab.activity),
                  ),
                AnalyticsStatus.loaded => _AnalyticsContent(state: state),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({required this.state});

  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final data = state.data!;

    return RefreshIndicator(
      color: AppColorPalette.primary,
      backgroundColor: AppColorPalette.darkCard,
      onRefresh: () async {
        context.read<AnalyticsBloc>().add(const RefreshAnalytics());
        await context.read<AnalyticsBloc>().stream.firstWhere(
              (next) =>
                  next.status == AnalyticsStatus.loaded ||
                  next.status == AnalyticsStatus.empty ||
                  next.status == AnalyticsStatus.failure,
            );
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Analytics',
                    style: TextStyle(
                      color: AppColorPalette.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your training trends, records, and insights.',
                    style: TextStyle(
                      color: AppColorPalette.grey400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                HomeAnimatedSection(
                  index: 0,
                  child: AnalyticsSummaryCards(summary: data.summary),
                ),
                const SizedBox(height: AppSpacing.xl),
                HomeAnimatedSection(
                  index: 1,
                  child: AnalyticsWeeklyChart(
                    weeklyActivity: data.weeklyActivity,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                HomeAnimatedSection(
                  index: 2,
                  child: AnalyticsMonthlyTrendChart(
                    monthlyTrends: data.monthlyTrends,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                HomeAnimatedSection(
                  index: 3,
                  child: AnalyticsActivityPieChart(
                    distribution: data.activityDistribution,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                HomeAnimatedSection(
                  index: 4,
                  child: AnalyticsPersonalRecords(
                    records: data.personalRecords,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                HomeAnimatedSection(
                  index: 5,
                  child: AnalyticsStreakSection(
                    streakStats: data.streakStats,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                HomeAnimatedSection(
                  index: 6,
                  child: AnalyticsGoalProgress(goals: data.goalProgress),
                ),
                const SizedBox(height: AppSpacing.xl),
                HomeAnimatedSection(
                  index: 7,
                  child: AnalyticsInsightsSection(insights: data.insights),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
