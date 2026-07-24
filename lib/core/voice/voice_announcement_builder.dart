import 'voice_settings.dart';
import 'voice_speech_formatter.dart';

/// Builds natural-language workout announcements from live metrics.
class VoiceAnnouncementBuilder {
  const VoiceAnnouncementBuilder();

  String workoutStarted() => 'Workout started.';

  String workoutPaused() => 'Workout paused.';

  String workoutResumed() => 'Workout resumed.';

  String distanceGoalCompleted() => 'Distance goal completed.';

  String timeGoalCompleted() => 'Time goal completed.';

  String distanceMilestone({
    required int markerIndex,
    required int intervalMeters,
    required Duration elapsed,
    required double averageSpeedMps,
    required double currentSpeedMps,
    required int calories,
    required VoiceAnnouncementContent content,
  }) {
    final parts = <String>[
      VoiceSpeechFormatter.distanceMilestone(
        markerIndex: markerIndex,
        intervalMeters: intervalMeters,
      ),
      'Time ${VoiceSpeechFormatter.duration(elapsed)}.',
    ];

    if (content.pace) {
      parts.add(
        'Average pace ${VoiceSpeechFormatter.pacePerKm(averageSpeedMps)}.',
      );
    }

    if (content.speed) {
      parts.add(
        'Current speed ${VoiceSpeechFormatter.speedKmh(currentSpeedMps)}.',
      );
    }

    if (content.calories) {
      parts.add(VoiceSpeechFormatter.calories(calories));
    }

    return parts.join(' ');
  }

  String timeCheckpoint({
    required Duration elapsed,
    required double distanceMeters,
    required double averageSpeedMps,
    required int calories,
    required VoiceAnnouncementContent content,
  }) {
    final parts = <String>[VoiceSpeechFormatter.timeCheckpoint(elapsed)];

    if (content.distance) {
      parts.add('Distance ${VoiceSpeechFormatter.distanceKm(distanceMeters)}.');
    }
    if (content.pace) {
      parts.add(
        'Average pace ${VoiceSpeechFormatter.pacePerKm(averageSpeedMps)}.',
      );
    }
    if (content.calories) {
      parts.add(VoiceSpeechFormatter.calories(calories));
    }

    return parts.join(' ');
  }

  String workoutCompleted() => 'Workout completed.';
}
