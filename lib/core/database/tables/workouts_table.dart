import 'package:drift/drift.dart';

/// Persisted workout sessions recorded from live activity tracking.
@DataClassName('WorkoutRow')
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get activityType => text().withLength(min: 1, max: 50)();

  DateTimeColumn get startTime => dateTime()();

  DateTimeColumn get endTime => dateTime()();

  IntColumn get durationInSeconds => integer()();

  RealColumn get distanceInMeters => real()();

  RealColumn get averageSpeed => real()();

  RealColumn get maxSpeed => real()();

  IntColumn get calories => integer()();

  TextColumn get polyline => text()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
