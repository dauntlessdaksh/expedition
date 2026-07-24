import 'package:drift/drift.dart';

/// Application settings persisted locally.
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get theme =>
      text().withDefault(const Constant('system'))();

  TextColumn get unit =>
      text().withDefault(const Constant('metric'))();

  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();

  IntColumn get dailyStepGoal =>
      integer().withDefault(const Constant(10000))();

  RealColumn get weeklyDistanceGoal =>
      real().withDefault(const Constant(56.0))();

  IntColumn get weeklyWorkoutGoal =>
      integer().withDefault(const Constant(12))();

  IntColumn get dailyActiveMinutesGoal =>
      integer().withDefault(const Constant(60))();

  IntColumn get monthlyWorkoutGoal =>
      integer().withDefault(const Constant(12))();
}
