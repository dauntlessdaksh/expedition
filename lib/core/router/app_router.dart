import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/data/services/location_service.dart';
import '../../features/activity/presentation/bloc/activity_bloc.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/avatar_test/presentation/screens/avatar_test_screen.dart';
import '../../features/history/data/repositories/workout_repository.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/data/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'page_transitions.dart';
import 'route_constants.dart';

/// Centralized router configuration for the Expedition application.
class AppRouter {
  AppRouter({
    required OnboardingRepository onboardingRepository,
    required HomeRepository homeRepository,
    required WorkoutRepository workoutRepository,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    router = GoRouter(
      navigatorKey: this.navigatorKey,
      initialLocation: RouteConstants.splash,
      debugLogDiagnostics: true,
      observers: [routeObserver],
      routes: _buildRoutes(
        onboardingRepository,
        homeRepository,
        workoutRepository,
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
      GoRoute(
        path: RouteConstants.home,
        name: RouteConstants.homeName,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => HomeBloc(repository: homeRepository)
              ..add(const LoadDashboard()),
            child: const HomeScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteConstants.activity,
        name: RouteConstants.activityName,
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => ActivityBloc(
              locationService: LocationService(),
              workoutRepository: workoutRepository,
              onboardingRepository: onboardingRepository,
            )..add(const ActivityStarted()),
            child: const ActivityScreen(),
          ),
        ),
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
