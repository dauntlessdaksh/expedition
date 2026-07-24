import 'package:drift/drift.dart';

/// Weekly and generated fitness challenges.
@DataClassName('ChallengeRow')
class Challenges extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().withLength(min: 1, max: 255)();

  TextColumn get type => text().withLength(min: 1, max: 64)();

  RealColumn get targetValue => real()();

  RealColumn get currentValue =>
      real().withDefault(const Constant(0))();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime()();

  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
