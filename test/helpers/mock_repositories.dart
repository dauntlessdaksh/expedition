import 'package:expedition/features/analytics/data/repositories/analytics_repository.dart';
import 'package:expedition/features/history/data/repositories/workout_repository.dart';
import 'package:expedition/features/home/data/repositories/home_repository.dart';
import 'package:expedition/features/history/data/repositories/history_repository.dart';
import 'package:expedition/features/profile/data/repositories/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}
