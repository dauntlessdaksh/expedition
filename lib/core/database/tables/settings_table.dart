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
}
