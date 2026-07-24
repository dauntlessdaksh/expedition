import 'package:drift/drift.dart';

/// Local user profile stored after onboarding completes.
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get gender => text().withLength(min: 1, max: 20)();

  IntColumn get age => integer()();

  RealColumn get height => real()();

  RealColumn get weight => real()();

  TextColumn get fitnessGoal => text().withLength(min: 1, max: 50)();

  TextColumn get activityLevel => text().withLength(min: 1, max: 50)();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
