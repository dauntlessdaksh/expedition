import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/data/services/location_service.dart';
import '../../features/activity/presentation/bloc/activity_bloc.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/activity/presentation/widgets/activity_tab_scope.dart';
import '../../features/avatar_test/presentation/screens/avatar_test_screen.dart';
import '../../features/gamification/data/repositories/achievement_repository.dart';
import '../../features/gamification/data/repositories/challenge_repository.dart';
import '../../features/gamification/data/repositories/gamification_repository.dart';
import '../../features/gamification/data/repositories/goal_repository.dart';
import '../../features/gamification/presentation/bloc/achievement_bloc.dart';
import '../../features/gamification/presentation/bloc/challenge_bloc.dart';
import '../../features/gamification/presentation/bloc/goal_bloc.dart';
import '../../features/gamification/presentation/screens/gamification_screen.dart';
import '../../features/history/data/repositories/history_repository.dart';
import '../../features/history/data/repositories/workout_repository.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/history/presentation/screens/workout_detail_screen.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/data/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/analytics/data/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/spotify/data/spotify_repository.dart';
import '../../features/spotify/presentation/bloc/spotify_bloc.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../navigation/bottom_navigation_shell.dart';
import 'page_transitions.dart';
import 'route_constants.dart';

/// Centralized router configuration for the Expedition application.
class AppRouter {
  AppRouter({
    required OnboardingRepository onboardingRepository,
    required HomeRepository homeRepository,
    required WorkoutRepository workoutRepository,
    required HistoryRepository historyRepository,
    required AnalyticsRepository analyticsRepository,
    required ProfileRepository profileRepository,
    required GamificationRepository gamificationRepository,
    required AchievementRepository achievementRepository,
    required GoalRepository goalRepository,
    required ChallengeRepository challengeRepository,
    required SpotifyRepository spotifyRepository,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    router = GoRouter(
      navigatorKey: this.navigatorKey,
      initialLocation: RouteConstants.splash,
      debugLogDiagnostics: kDebugMode,
      observers: [routeObserver],
      routes: _buildRoutes(
        onboardingRepository,
        homeRepository,
        workoutRepository,
        historyRepository,
        analyticsRepository,
        profileRepository,
        gamificationRepository,
        achievementRepository,
        goalRepository,
        challengeRepository,
        spotifyRepository,
      ),
    );
  }

  final GlobalKey<NavigatorState> navigatorKey;
  late final GoRouter router;

  /// Tracks when a route is covered so heavy widgets (e.g. 3D avatar WebView)
  /// can pause before another platform view (Google Maps) mounts.
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  static List<RouteBase> _buildRoutes(
    OnboardingRepository onboardingRepository,
    HomeRepository homeRepository,
    WorkoutRepository workoutRepository,
    HistoryRepository historyRepository,
    AnalyticsRepository analyticsRepository,
    ProfileRepository profileRepository,
    GamificationRepository gamificationRepository,
    AchievementRepository achievementRepository,
    GoalRepository goalRepository,
    ChallengeRepository challengeRepository,
    SpotifyRepository spotifyRepository,
  ) {
    return [
      GoRoute(
        path: RouteConstants.splash,
        name: RouteConstants.splashName,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => SplashBloc(
              onboardingRepository: onboardingRepository,
            ),
            child: const SplashScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        name: RouteConstants.onboardingName,
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => OnboardingBloc(repository: onboardingRepository)
              ..add(const OnboardingStarted()),
            child: const OnboardingFlowScreen(),
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ActivityBloc(
                  locationService: LocationService(),
                  workoutRepository: workoutRepository,
                  onboardingRepository: onboardingRepository,
                  gamificationRepository: gamificationRepository,
                ),
              ),
              BlocProvider(
                create: (_) => SpotifyBloc(repository: spotifyRepository)
                  ..add(const RestoreSpotifySession()),
              ),
            ],
            child: BottomNavigationShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.home,
                name: RouteConstants.homeName,
                pageBuilder: (context, state) => shellTransitionPage(
                  key: state.pageKey,
                  child: BlocProvider(
                    create: (_) => HomeBloc(
                      repository: homeRepository,
                    )..add(const LoadDashboard()),
                    child: const HomeScreen(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: RouteConstants.settings,
                    name: RouteConstants.settingsName,
                    pageBuilder: (context, state) => heroSlideTransitionPage(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (_) =>
                            ProfileBloc(repository: profileRepository)
                              ..add(const LoadProfile()),
                        child: const SettingsScreen(),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RouteConstants.profile,
                    name: RouteConstants.profileName,
                    pageBuilder: (context, state) => heroSlideTransitionPage(
                      key: state.pageKey,
                      child: BlocProvider(
                        create: (_) =>
                            ProfileBloc(repository: profileRepository)
                              ..add(const LoadProfile()),
                        child: const ProfileScreen(),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: RouteConstants.gamification,
                    name: RouteConstants.gamificationName,
                    pageBuilder: (context, state) => heroSlideTransitionPage(
                      key: state.pageKey,
                      child: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => AchievementBloc(
                              repository: achievementRepository,
                            )..add(const LoadAchievements()),
                          ),
                          BlocProvider(
                            create: (_) => GoalBloc(repository: goalRepository)
                              ..add(const LoadGoals()),
                          ),
                          BlocProvider(
                            create: (_) => ChallengeBloc(
                              repository: challengeRepository,
                            )..add(const LoadChallenges()),
                          ),
                        ],
                        child: const GamificationScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.activity,
                name: RouteConstants.activityName,
                pageBuilder: (context, state) => shellTransitionPage(
                  key: state.pageKey,
                  child: const ActivityTabScope(
                    child: ActivityScreen(),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.analytics,
                name: RouteConstants.analyticsName,
                pageBuilder: (context, state) => shellTransitionPage(
                  key: state.pageKey,
                  child: BlocProvider(
                    create: (_) => AnalyticsBloc(
                      repository: analyticsRepository,
                    )..add(const LoadAnalytics()),
                    child: const AnalyticsScreen(),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ShellRoute(
                builder: (context, state, child) {
                  return BlocProvider(
                    create: (_) => HistoryBloc(repository: historyRepository)
                      ..add(const LoadHistory()),
                    child: child,
                  );
                },
                routes: [
                  GoRoute(
                    path: RouteConstants.history,
                    name: RouteConstants.historyName,
                    pageBuilder: (context, state) => shellTransitionPage(
                      key: state.pageKey,
                      child: const HistoryScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: RouteConstants.historyDetailName,
                        pageBuilder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);

                          return heroSlideTransitionPage(
                            key: state.pageKey,
                            child: WorkoutDetailScreen(workoutId: id),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.avatarTest,
        name: RouteConstants.avatarTestName,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const AvatarTestScreen(),
        ),
      ),
    ];
  }
}
