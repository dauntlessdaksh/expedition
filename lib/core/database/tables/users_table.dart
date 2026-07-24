import 'package:drift/drift.dart';

/// Local user profile stored during onboarding.
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  DateTimeColumn get dateOfBirth => dateTime()();

  TextColumn get gender => text().withLength(min: 1, max: 20)();

  RealColumn get height => real()();

  RealColumn get weight => real()();

  TextColumn get hairStyle => text().nullable()();

  TextColumn get skinTone => text().nullable()();

  TextColumn get outfitColor => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
