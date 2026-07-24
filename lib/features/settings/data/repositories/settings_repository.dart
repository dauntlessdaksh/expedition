import '../datasource/settings_local_datasource.dart';
import '../models/settings_model.dart';

/// Repository for application settings operations.
class SettingsRepository {
  const SettingsRepository(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  Future<SettingsModel?> getSettings() => _localDataSource.getSettings();

  Future<SettingsModel> ensureDefaultSettings() =>
      _localDataSource.ensureDefaultSettings();

  Future<void> updateNotifications({required bool enabled}) =>
      _localDataSource.updateNotifications(enabled: enabled);
}
