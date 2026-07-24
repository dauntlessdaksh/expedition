import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/shell_tab_index_scope.dart';
import '../../../../core/navigation/main_tab.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/services/avatar_lifecycle.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/skeleton/skeleton_loaders.dart';
import '../../domain/models/home_dashboard_data.dart';
import '../bloc/home_bloc.dart';
import '../widgets/daily_steps_progress_bar.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/hourly_activity_graph.dart';

/// Premium fitness dashboard matching the reference home layout.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, AutomaticKeepAliveClientMixin {
  bool _isRouteVisible = true;

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
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    setState(() => _isRouteVisible = false);
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
    setState(() => _isRouteVisible = true);
    context.read<HomeBloc>().add(const RefreshDashboard());
  }

  bool _isHomeTabActive(BuildContext context) {
    return ShellTabIndexScope.indexOf(context) == MainTab.home.branchIndex;
  }

  bool _isActivityTabActive(BuildContext context) {
    return ShellTabIndexScope.indexOf(context) == MainTab.activity.branchIndex;
  }

  bool _isProfileOpen(BuildContext context) {
    return GoRouterState.of(context).uri.toString().contains(
          RouteConstants.profile,
        );
  }

  /// Hide the avatar visually but keep the WebView alive (History/Analytics).
  bool _isAvatarVisible(BuildContext context) {
    return _isRouteVisible && _isHomeTabActive(context);
  }

  /// Tear down the WebView so Google Maps / Profile avatar can use it.
  bool _shouldSuspendAvatar(BuildContext context) {
    if (!_isRouteVisible) {
      return true;
    }

    if (_isActivityTabActive(context)) {
      return true;
    }

    if (_isProfileOpen(context)) {
      return true;
    }

    if (avatarHostLock.value != null && avatarHostLock.value != 'home') {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final avatarVisible = _isAvatarVisible(context);
    final avatarSuspended = _shouldSuspendAvatar(context);

    return Scaffold(
      backgroundColor: AppColorPalette.black,
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
              _DashboardContent(
                data: state.data!,
                avatarVisible: avatarVisible,
                avatarSuspended: avatarSuspended,
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.avatarVisible,
    required this.avatarSuspended,
  });

  final HomeDashboardData data;
  final bool avatarVisible;
  final bool avatarSuspended;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColorPalette.primary,
      backgroundColor: AppColorPalette.darkCard,
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
                        gender: data.gender,
                        stats: data.stats,
                        avatarVisible: avatarVisible,
                        avatarSuspended: avatarSuspended,
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
