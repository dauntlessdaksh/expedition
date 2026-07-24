import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/constants/app_strings.dart';
import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'core/services/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/logger.dart';
import 'features/analytics/data/repositories/analytics_repository.dart';
import 'features/gamification/data/datasource/gamification_local_datasource.dart';
import 'features/gamification/data/repositories/achievement_repository.dart';
import 'features/gamification/data/repositories/challenge_repository.dart';
import 'features/gamification/data/repositories/gamification_repository.dart';
import 'features/gamification/data/repositories/goal_repository.dart';
import 'features/history/data/datasource/workout_local_datasource.dart';
import 'features/history/data/repositories/history_repository.dart';
import 'features/history/data/repositories/workout_repository.dart';
import 'features/home/data/repositories/home_repository.dart';
import 'features/onboarding/data/datasource/onboarding_local_datasource.dart';
import 'features/onboarding/data/repositories/onboarding_repository.dart';
import 'features/profile/data/datasource/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository.dart';
import 'features/spotify/data/spotify_auth_service.dart';
import 'features/spotify/data/spotify_remote_service.dart';
import 'features/spotify/data/spotify_repository.dart';
import 'core/voice/voice_service.dart';
import 'core/voice/voice_settings_service.dart';

/// Root widget for the Expedition application.
class ExpeditionApp extends StatelessWidget {
  const ExpeditionApp({
    required this.appRouter,
    super.key,
  });

  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: appRouter.router,
        );
      },
    );
  }
}

/// Initializes core services and launches the application.
Future<void> bootstrap() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AppLogger.info('Bootstrapping Expedition...');

  final database = AppDatabase();
  final apiClient = ApiClient();

  final profileLocalDataSource = ProfileLocalDataSource(database);
  final gamificationLocalDataSource = GamificationLocalDataSource(database);

  final onboardingRepository = OnboardingRepository(
    OnboardingLocalDataSource(database),
  );

  final workoutRepository = WorkoutRepository(
    WorkoutLocalDataSource(database),
  );

  final historyRepository = HistoryRepository(workoutRepository);

  final gamificationRepository = GamificationRepository(
    localDataSource: gamificationLocalDataSource,
    workoutRepository: workoutRepository,
    profileLocalDataSource: profileLocalDataSource,
  );

  final achievementRepository = AchievementRepository(gamificationRepository);
  final goalRepository = GoalRepository(gamificationRepository);
  final challengeRepository = ChallengeRepository(gamificationRepository);

  final profileRepository = ProfileRepository(
    localDataSource: profileLocalDataSource,
    workoutRepository: workoutRepository,
    achievementRepository: achievementRepository,
  );

  final themeCubit = ThemeCubit(
    initialMode: ThemeMode.system,
  );

  final homeRepository = HomeRepository(
    workoutRepository: workoutRepository,
    onboardingRepository: onboardingRepository,
    profileRepository: profileRepository,
  );

  final analyticsRepository = AnalyticsRepository(
    workoutRepository: workoutRepository,
    profileRepository: profileRepository,
  );

  final spotifyRepository = SpotifyRepository(
    authService: SpotifyAuthService(dio: apiClient.dio),
    remoteService: SpotifyRemoteService(),
  );

  final voiceSettingsService = VoiceSettingsService();
  final voiceService = VoiceService();

  final appRouter = AppRouter(
    onboardingRepository: onboardingRepository,
    homeRepository: homeRepository,
    workoutRepository: workoutRepository,
    historyRepository: historyRepository,
    analyticsRepository: analyticsRepository,
    profileRepository: profileRepository,
    gamificationRepository: gamificationRepository,
    achievementRepository: achievementRepository,
    goalRepository: goalRepository,
    challengeRepository: challengeRepository,
    spotifyRepository: spotifyRepository,
  );

  AppLogger.info('Core services initialized');

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: database),
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<OnboardingRepository>.value(
          value: onboardingRepository,
        ),
        RepositoryProvider<WorkoutRepository>.value(value: workoutRepository),
        RepositoryProvider<HistoryRepository>.value(value: historyRepository),
        RepositoryProvider<HomeRepository>.value(value: homeRepository),
        RepositoryProvider<AnalyticsRepository>.value(
          value: analyticsRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: profileRepository,
        ),
        RepositoryProvider<GamificationRepository>.value(
          value: gamificationRepository,
        ),
        RepositoryProvider<AchievementRepository>.value(
          value: achievementRepository,
        ),
        RepositoryProvider<GoalRepository>.value(value: goalRepository),
        RepositoryProvider<ChallengeRepository>.value(
          value: challengeRepository,
        ),
        RepositoryProvider<SpotifyRepository>.value(
          value: spotifyRepository,
        ),
        RepositoryProvider<VoiceSettingsService>.value(
          value: voiceSettingsService,
        ),
        RepositoryProvider<VoiceService>.value(
          value: voiceService,
        ),
      ],
      child: BlocProvider.value(
        value: themeCubit,
        child: ExpeditionApp(appRouter: appRouter),
      ),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
    unawaited(_warmUpAfterFirstFrame(
      profileRepository: profileRepository,
      themeCubit: themeCubit,
      gamificationRepository: gamificationRepository,
      voiceService: voiceService,
    ));
  });
}

Future<void> _warmUpAfterFirstFrame({
  required ProfileRepository profileRepository,
  required ThemeCubit themeCubit,
  required GamificationRepository gamificationRepository,
  required VoiceService voiceService,
}) async {
  try {
    final preferences = await profileRepository.getPreferences();
    themeCubit.setThemeMode(
      ThemeCubit.modeFromPreference(preferences.theme),
    );
  } on Exception {
    // Keep system theme when preferences is unavailable.
  }

  unawaited(voiceService.initialize());
  unawaited(gamificationRepository.refresh());
}
