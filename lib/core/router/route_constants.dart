/// Centralized route path constants for GoRouter navigation.
abstract final class RouteConstants {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String activity = '/activity';
  static const String history = '/history';
  static const String analytics = '/analytics';
  static const String avatarTest = '/avatar-test';

  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String homeName = 'home';
  static const String activityName = 'activity';
  static const String historyName = 'history';
  static const String historyDetailName = 'historyDetail';
  static const String analyticsName = 'analytics';
  static const String avatarTestName = 'avatar-test';

  static String historyDetailPath(int id) => '$history/$id';

  static const String profile = 'profile';
  static String get profilePath => '$home/$profile';
  static const String profileName = 'profile';

  static const String gamification = 'gamification';
  static String get gamificationPath => '$home/$gamification';
  static const String gamificationName = 'gamification';
}
