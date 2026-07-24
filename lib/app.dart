import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'core/services/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/logger.dart';
import 'features/home/data/repositories/dummy_home_repository.dart';
import 'features/onboarding/data/datasource/onboarding_local_datasource.dart';
import 'features/onboarding/data/repositories/onboarding_repository.dart';

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
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Bootstrapping Expedition...');

  final database = AppDatabase();
  final apiClient = ApiClient();

  final onboardingRepository = OnboardingRepository(
    OnboardingLocalDataSource(database),
  );

  final homeRepository = DummyHomeRepository(
    onboardingRepository: onboardingRepository,
  );

  final appRouter = AppRouter(
    onboardingRepository: onboardingRepository,
    homeRepository: homeRepository,
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
        RepositoryProvider<DummyHomeRepository>.value(value: homeRepository),
      ],
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: ExpeditionApp(appRouter: appRouter),
      ),
    ),
  );
}
