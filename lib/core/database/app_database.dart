import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/settings_table.dart';
import 'tables/users_table.dart';

part 'app_database.g.dart';

/// Local SQLite database for offline-first data persistence.
@DriftDatabase(tables: [Users, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(users);
          await m.createTable(settings);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'expedition');
  }
}
