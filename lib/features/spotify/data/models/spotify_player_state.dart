import 'package:equatable/equatable.dart';

import 'spotify_track.dart';

/// Playback snapshot from the Spotify App Remote SDK.
class SpotifyPlayerState extends Equatable {
  const SpotifyPlayerState({
    this.track,
    this.isPlaying = false,
    this.positionMs = 0,
    this.durationMs = 0,
    this.isShuffleEnabled = false,
    this.repeatMode = SpotifyRepeatMode.off,
  });

  final SpotifyTrack? track;
  final bool isPlaying;
  final int positionMs;
  final int durationMs;
  final bool isShuffleEnabled;
  final SpotifyRepeatMode repeatMode;

  SpotifyPlayerState copyWith({
    SpotifyTrack? track,
    bool? isPlaying,
    int? positionMs,
    int? durationMs,
    bool? isShuffleEnabled,
    SpotifyRepeatMode? repeatMode,
  }) {
    return SpotifyPlayerState(
      track: track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  @override
  List<Object?> get props => [
        track,
        isPlaying,
        positionMs,
        durationMs,
        isShuffleEnabled,
        repeatMode,
      ];
}

enum SpotifyRepeatMode {
  off,
  track,
  context;

  static SpotifyRepeatMode fromSdkValue(int? value) {
    return switch (value) {
      1 => SpotifyRepeatMode.context,
      2 => SpotifyRepeatMode.track,
      _ => SpotifyRepeatMode.off,
    };
  }
}
