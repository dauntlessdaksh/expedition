import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/services/profile_sync_notifier.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/skeleton/skeleton_loaders.dart';
import '../../domain/models/home_dashboard_data.dart';
import '../bloc/home_bloc.dart';
import '../widgets/daily_steps_progress_bar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/hourly_activity_graph.dart';

/// Premium fitness dashboard matching the reference home layout.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void initState() {
    super.initState();
    profileSyncNotifier.addListener(_onProfileSync);
  }

  @override
  void dispose() {
    profileSyncNotifier.removeListener(_onProfileSync);
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _onProfileSync() {
    if (mounted) {
      context.read<HomeBloc>().add(const RefreshDashboard());
    }
  }

  @override
  void activate() {
    super.activate();
    if (mounted) {
      context.read<HomeBloc>().add(const RefreshDashboard());
    }
  }

  @override
  void didPopNext() {
    context.read<HomeBloc>().add(const RefreshDashboard());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: context.expeditionColors.scaffoldBackground,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state.status) {
            HomeStatus.initial || HomeStatus.loading =>
              SkeletonLoaders.dashboard(),
            HomeStatus.failure => AppErrorView.fromError(
                StateError('Unable to load dashboard'),
                onRetry: () =>
                    context.read<HomeBloc>().add(const LoadDashboard()),
              ),
            HomeStatus.loaded when state.data != null =>
              _DashboardContent(data: state.data!),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return RefreshIndicator(
      color: AppColorPalette.primary,
      backgroundColor: colors.card,
      onRefresh: () async {
        context.read<HomeBloc>().add(const RefreshDashboard());
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.40,
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                            HomeTopBar(
                              userName: data.userName,
                              onSettingsTap: () => context.pushNamed(
                                RouteConstants.settingsName,
                              ),
                            ),
                            Expanded(
                              child: HourlyActivityGraph(
                                hourlyActivity: data.hourlyActivity,
                                totalSteps: data.stats.steps,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                0,
                                AppSpacing.xl,
                                AppSpacing.sm,
                              ),
                              child: DailyStepsProgressBar(
                                stats: data.stats,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: HomeHeroSection(
                        stats: data.stats,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
