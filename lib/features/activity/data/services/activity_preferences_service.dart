import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/activity_preferences.dart';

/// Persists activity preferences to local app storage.
class ActivityPreferencesService {
  static const _fileName = 'activity_preferences.json';

  Future<ActivityPreferences> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return ActivityPreferences.defaults;
      }
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return ActivityPreferences.fromJson(json);
    } on Exception {
      return ActivityPreferences.defaults;
    }
  }

  Future<void> save(ActivityPreferences preferences) async {
    final file = await _file();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(preferences.toJson()),
    );
  }

  Future<void> reset() => save(ActivityPreferences.defaults);

  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
