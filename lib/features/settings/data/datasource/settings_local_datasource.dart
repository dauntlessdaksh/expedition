import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/settings_model.dart';

/// Data source for local settings persistence via Drift.
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._database);

  final AppDatabase _database;

  Future<SettingsModel?> getSettings() async {
    final settings = await (_database.select(_database.settings)
          ..limit(1))
        .getSingleOrNull();

    if (settings == null) return null;
    return _mapToModel(settings);
  }

  Future<SettingsModel> ensureDefaultSettings() async {
    final existing = await getSettings();
    if (existing != null) return existing;

    final id = await _database.into(_database.settings).insert(
          const SettingsCompanion(),
        );

    final settings = await (_database.select(_database.settings)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();

    return _mapToModel(settings);
  }

  Future<void> updateNotifications({required bool enabled}) async {
    final settings = await getSettings();
    if (settings == null) return;

    await (_database.update(_database.settings)
          ..where((tbl) => tbl.id.equals(settings.id)))
        .write(
      SettingsCompanion(
        notificationsEnabled: Value(enabled),
      ),
    );
  }

  SettingsModel _mapToModel(Setting setting) {
    return SettingsModel(
      id: setting.id,
      theme: setting.theme,
      unit: setting.unit,
      notificationsEnabled: setting.notificationsEnabled,
      dailyStepGoal: setting.dailyStepGoal,
    );
  }
}
