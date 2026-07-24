import 'package:drift/drift.dart';

/// Persisted fitness goal targets and current progress.
@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  RealColumn get targetValue => real()();

  RealColumn get currentValue =>
      real().withDefault(const Constant(0))();

  TextColumn get period => text().withLength(min: 1, max: 32)();

  DateTimeColumn get periodStart => dateTime()();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
