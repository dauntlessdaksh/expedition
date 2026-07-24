import 'package:expedition/core/voice/voice_announcement_builder.dart';
import 'package:expedition/core/voice/voice_settings.dart';
import 'package:expedition/core/voice/voice_speech_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceSpeechFormatter', () {
    test('formats duration with hours minutes seconds', () {
      expect(
        VoiceSpeechFormatter.duration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        'one hour two minutes three seconds',
      );
    });

    test('formats kilometer milestones naturally', () {
      expect(
        VoiceSpeechFormatter.distanceMilestone(
          markerIndex: 1,
          intervalMeters: 1000,
        ),
        'One kilometer completed.',
      );
      expect(
        VoiceSpeechFormatter.distanceMilestone(
          markerIndex: 2,
          intervalMeters: 1000,
        ),
        'Distance two kilometers.',
      );
    });
  });

  group('VoiceAnnouncementBuilder', () {
    const builder = VoiceAnnouncementBuilder();

    test('builds kilometer announcement with pace and speed', () {
      final text = builder.distanceMilestone(
        markerIndex: 1,
        intervalMeters: 1000,
        elapsed: const Duration(minutes: 5, seconds: 32),
        averageSpeedMps: 3.0,
        currentSpeedMps: 3.0,
        calories: 68,
        content: const VoiceAnnouncementContent(),
      );

      expect(text, contains('One kilometer completed.'));
      expect(text, contains('Time five minutes thirty two seconds.'));
      expect(text, contains('Average pace'));
      expect(text, contains('Current speed'));
      expect(text, contains('sixty eight calories burned'));
    });

    test('builds short completion announcement', () {
      expect(const VoiceAnnouncementBuilder().workoutCompleted(),
          'Workout completed.');
    });
  });
}
