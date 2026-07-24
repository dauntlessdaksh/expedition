import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'core/services/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/logger.dart';
import 'features/profile/data/datasource/user_local_datasource.dart';
import 'features/profile/data/repositories/user_repository.dart';
import 'features/settings/data/datasource/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository.dart';

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

  final userRepository = UserRepository(
    UserLocalDataSource(database),
  );
  final settingsRepository = SettingsRepository(
    SettingsLocalDataSource(database),
  );

  final appRouter = AppRouter(
    userRepository: userRepository,
    settingsRepository: settingsRepository,
  );

  AppLogger.info('Core services initialized');

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: database),
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<SettingsRepository>.value(
          value: settingsRepository,
        ),
      ],
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: ExpeditionApp(appRouter: appRouter),
      ),
    ),
  );
}
