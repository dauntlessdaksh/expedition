import 'package:equatable/equatable.dart';

/// Distance interval for milestone announcements.
enum VoiceAnnouncementDistance {
  meters500(500),
  kilometers1(1000),
  kilometers2(2000);

  const VoiceAnnouncementDistance(this.meters);

  final int meters;

  String get label => switch (this) {
        VoiceAnnouncementDistance.meters500 => '500 m',
        VoiceAnnouncementDistance.kilometers1 => '1 km',
        VoiceAnnouncementDistance.kilometers2 => '2 km',
      };

  static VoiceAnnouncementDistance fromStorage(String? value) {
    return VoiceAnnouncementDistance.values.firstWhere(
      (item) => item.name == value,
      orElse: () => VoiceAnnouncementDistance.kilometers1,
    );
  }
}

/// Periodic time-based announcements during a workout.
enum VoiceTimeInterval {
  none(0),
  minutes5(5),
  minutes10(10);

  const VoiceTimeInterval(this.minutes);

  final int minutes;

  String get label => switch (this) {
        VoiceTimeInterval.none => 'None',
        VoiceTimeInterval.minutes5 => 'Every 5 min',
        VoiceTimeInterval.minutes10 => 'Every 10 min',
      };

  static VoiceTimeInterval fromStorage(String? value) {
    return VoiceTimeInterval.values.firstWhere(
      (item) => item.name == value,
      orElse: () => VoiceTimeInterval.none,
    );
  }
}

/// TTS playback speed presets mapped to flutter_tts speech rates.
enum VoiceSpeakingRate {
  slow(0.42),
  normal(0.5),
  fast(0.58);

  const VoiceSpeakingRate(this.rate);

  final double rate;

  String get label => switch (this) {
        VoiceSpeakingRate.slow => 'Slow',
        VoiceSpeakingRate.normal => 'Normal',
        VoiceSpeakingRate.fast => 'Fast',
      };

  static VoiceSpeakingRate fromStorage(String? value) {
    return VoiceSpeakingRate.values.firstWhere(
      (item) => item.name == value,
      orElse: () => VoiceSpeakingRate.normal,
    );
  }
}

/// Toggleable announcement content fields.
class VoiceAnnouncementContent extends Equatable {
  const VoiceAnnouncementContent({
    this.distance = true,
    this.pace = true,
    this.speed = true,
    this.calories = true,
    this.elevation = false,
    this.gpsStatus = false,
  });

  final bool distance;
  final bool pace;
  final bool speed;
  final bool calories;
  final bool elevation;
  final bool gpsStatus;

  VoiceAnnouncementContent copyWith({
    bool? distance,
    bool? pace,
    bool? speed,
    bool? calories,
    bool? elevation,
    bool? gpsStatus,
  }) {
    return VoiceAnnouncementContent(
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
      speed: speed ?? this.speed,
      calories: calories ?? this.calories,
      elevation: elevation ?? this.elevation,
      gpsStatus: gpsStatus ?? this.gpsStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'pace': pace,
        'speed': speed,
        'calories': calories,
        'elevation': elevation,
        'gpsStatus': gpsStatus,
      };

  factory VoiceAnnouncementContent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VoiceAnnouncementContent();
    }
    return VoiceAnnouncementContent(
      distance: json['distance'] as bool? ?? true,
      pace: json['pace'] as bool? ?? true,
      speed: json['speed'] as bool? ?? true,
      calories: json['calories'] as bool? ?? true,
      elevation: json['elevation'] as bool? ?? false,
      gpsStatus: json['gpsStatus'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [distance, pace, speed, calories, elevation, gpsStatus];
}

/// Persisted voice guidance preferences.
class VoiceSettings extends Equatable {
  const VoiceSettings({
    this.enabled = false,
    this.announcementDistance = VoiceAnnouncementDistance.kilometers1,
    this.timeInterval = VoiceTimeInterval.none,
    this.content = const VoiceAnnouncementContent(),
    this.speakingRate = VoiceSpeakingRate.normal,
  });

  final bool enabled;
  final VoiceAnnouncementDistance announcementDistance;
  final VoiceTimeInterval timeInterval;
  final VoiceAnnouncementContent content;
  final VoiceSpeakingRate speakingRate;

  static const defaults = VoiceSettings(enabled: true);

  VoiceSettings copyWith({
    bool? enabled,
    VoiceAnnouncementDistance? announcementDistance,
    VoiceTimeInterval? timeInterval,
    VoiceAnnouncementContent? content,
    VoiceSpeakingRate? speakingRate,
  }) {
    return VoiceSettings(
      enabled: enabled ?? this.enabled,
      announcementDistance: announcementDistance ?? this.announcementDistance,
      timeInterval: timeInterval ?? this.timeInterval,
      content: content ?? this.content,
      speakingRate: speakingRate ?? this.speakingRate,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'announcementDistance': announcementDistance.name,
        'timeInterval': timeInterval.name,
        'content': content.toJson(),
        'speakingRate': speakingRate.name,
      };

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    return VoiceSettings(
      enabled: json['enabled'] as bool? ?? false,
      announcementDistance: VoiceAnnouncementDistance.fromStorage(
        json['announcementDistance'] as String?,
      ),
      timeInterval: VoiceTimeInterval.fromStorage(
        json['timeInterval'] as String?,
      ),
      content: VoiceAnnouncementContent.fromJson(
        json['content'] as Map<String, dynamic>?,
      ),
      speakingRate: VoiceSpeakingRate.fromStorage(
        json['speakingRate'] as String?,
      ),
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        announcementDistance,
        timeInterval,
        content,
        speakingRate,
      ];
}
