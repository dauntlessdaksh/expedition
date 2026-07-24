import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/models/home_dashboard_data.dart';
import '../bloc/home_bloc.dart';
import '../widgets/avatar_card.dart';
import '../widgets/greeting_section.dart';
import '../widgets/home_animated_section.dart';
import '../widgets/progress_card.dart';
import '../widgets/stats_grid.dart';
import '../widgets/streak_card.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/workout_fab.dart';

/// Premium fitness dashboard shown after onboarding completes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  bool _isRouteVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    setState(() => _isRouteVisible = false);
  }

  @override
  void didPopNext() {
    setState(() => _isRouteVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPalette.darkBackground,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: PremiumGradients.darkBackground,
        ),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return switch (state.status) {
              HomeStatus.initial || HomeStatus.loading =>
                const LoadingIndicator(message: 'Loading your dashboard...'),
              HomeStatus.failure => _ErrorView(
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeStarted()),
                ),
              HomeStatus.loaded when state.data != null =>
                _DashboardContent(
                  data: state.data!,
                  showAvatar: _isRouteVisible,
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.showAvatar,
  });

  final HomeDashboardData data;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColorPalette.primary,
          backgroundColor: AppColorPalette.darkCard,
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeRefreshed());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    0,
                  ),
                  child: HomeAnimatedSection(
                    index: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GreetingSection(userName: data.userName),
                        ),
                        ProfileButton(
                          onTap: () {
                            // Profile screen — coming soon.
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xxxl + 80 + bottomPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    HomeAnimatedSection(
                      index: 1,
                      child: AvatarCard(
                        gender: data.gender,
                        showAvatar: showAvatar,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    HomeAnimatedSection(
                      index: 2,
                      child: ProgressCard(stats: data.stats),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    HomeAnimatedSection(
                      index: 3,
                      child: StatsGrid(stats: data.stats),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    HomeAnimatedSection(
                      index: 4,
                      child: StreakCard(streakDays: data.streakDays),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    HomeAnimatedSection(
                      index: 5,
                      child: WeeklyChart(
                        weeklyActivity: data.weeklyActivity,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: WorkoutFab(
            onPressed: () => context.go(RouteConstants.activity),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColorPalette.error,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                color: AppColorPalette.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
