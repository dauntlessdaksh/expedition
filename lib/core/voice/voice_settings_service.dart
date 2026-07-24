import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'voice_settings.dart';

/// Persists [VoiceSettings] to local app storage.
class VoiceSettingsService {
  static const _fileName = 'voice_settings.json';

  Future<VoiceSettings> load({bool? legacyVoiceFeedbackEnabled}) async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        final legacy = legacyVoiceFeedbackEnabled ?? await _readLegacyVoiceFeedback();
        if (legacy == true) {
          return VoiceSettings.defaults.copyWith(enabled: true);
        }
        return VoiceSettings.defaults;
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return VoiceSettings.fromJson(json);
    } on Exception {
      if (legacyVoiceFeedbackEnabled == true) {
        return VoiceSettings.defaults.copyWith(enabled: true);
      }
      return VoiceSettings.defaults;
    }
  }

  Future<void> save(VoiceSettings settings) async {
    final file = await _file();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(settings.toJson()),
    );
  }

  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<bool?> _readLegacyVoiceFeedback() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final legacyFile = File('${directory.path}/activity_preferences.json');
      if (!await legacyFile.exists()) {
        return null;
      }
      final json =
          jsonDecode(await legacyFile.readAsString()) as Map<String, dynamic>;
      return json['voiceFeedback'] as bool?;
    } on Exception {
      return null;
    }
  }
}
