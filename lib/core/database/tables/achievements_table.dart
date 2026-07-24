import 'package:drift/drift.dart';

/// Persisted achievement progress and unlock state.
@DataClassName('AchievementRow')
class Achievements extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().withLength(min: 1, max: 255)();

  TextColumn get icon => text().withLength(min: 1, max: 16)();

  RealColumn get progress =>
      real().withDefault(const Constant(0))();

  RealColumn get currentValue =>
      real().withDefault(const Constant(0))();

  RealColumn get targetValue => real()();

  BoolColumn get isUnlocked =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get unlockedDate => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
