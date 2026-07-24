import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/avatar/presentation/bloc/avatar_bloc.dart';
import '../../features/avatar/presentation/screens/avatar_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/permissions/presentation/bloc/permission_bloc.dart';
import '../../features/permissions/presentation/screens/permissions_screen.dart';
import '../../features/profile/data/repositories/user_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'page_transitions.dart';
import 'route_constants.dart';

/// Centralized router configuration for the Expedition application.
class AppRouter {
  AppRouter({
    required UserRepository userRepository,
    required SettingsRepository settingsRepository,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : router = GoRouter(
          navigatorKey: navigatorKey,
          initialLocation: RouteConstants.splash,
          debugLogDiagnostics: true,
          routes: _buildRoutes(userRepository, settingsRepository),
        );

  final GoRouter router;

  static List<RouteBase> _buildRoutes(
    UserRepository userRepository,
    SettingsRepository settingsRepository,
  ) {
    return [
      GoRoute(
        path: RouteConstants.splash,
        name: RouteConstants.splashName,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => SplashBloc(userRepository: userRepository),
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
            create: (_) => OnboardingBloc(),
            child: const OnboardingScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: RouteConstants.profileName,
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => ProfileBloc(userRepository: userRepository),
            child: const ProfileScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteConstants.avatar,
        name: RouteConstants.avatarName,
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => AvatarBloc(userRepository: userRepository),
            child: const AvatarScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteConstants.permissions,
        name: RouteConstants.permissionsName,
        pageBuilder: (context, state) => fadeSlideTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => PermissionBloc(
              settingsRepository: settingsRepository,
            ),
            child: const PermissionsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: RouteConstants.home,
        name: RouteConstants.homeName,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),
    ];
  }
}
