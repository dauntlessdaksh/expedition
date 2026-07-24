import 'package:bloc_test/bloc_test.dart';
import 'package:expedition/features/activity/data/services/location_service.dart';
import 'package:expedition/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:expedition/features/gamification/data/repositories/gamification_repository.dart';
import 'package:expedition/features/history/data/repositories/workout_repository.dart';
import 'package:expedition/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockGamificationRepository extends Mock implements GamificationRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocationService locationService;
  late MockWorkoutRepository workoutRepository;
  late MockOnboardingRepository onboardingRepository;
  late MockGamificationRepository gamificationRepository;

  setUp(() {
    locationService = MockLocationService();
    workoutRepository = MockWorkoutRepository();
    onboardingRepository = MockOnboardingRepository();
    gamificationRepository = MockGamificationRepository();
  });

  blocTest<ActivityBloc, ActivityState>(
    'starts in initial state',
    build: () => ActivityBloc(
      locationService: locationService,
      workoutRepository: workoutRepository,
      onboardingRepository: onboardingRepository,
      gamificationRepository: gamificationRepository,
    ),
    verify: (bloc) {
      expect(bloc.state.status, ActivityTrackingStatus.initial);
      expect(bloc.state.permissionStatus, ActivityPermissionStatus.unknown);
    },
  );
}
