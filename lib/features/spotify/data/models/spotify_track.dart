import 'package:equatable/equatable.dart';

/// Domain representation of the currently playing Spotify track.
class SpotifyTrack extends Equatable {
  const SpotifyTrack({
    required this.uri,
    required this.name,
    required this.artist,
    required this.album,
    this.albumArtUrl,
    this.durationMs = 0,
  });

  final String uri;
  final String name;
  final String artist;
  final String album;
  final String? albumArtUrl;
  final int durationMs;

  bool get hasMetadata => name.isNotEmpty;

  SpotifyTrack copyWith({
    String? uri,
    String? name,
    String? artist,
    String? album,
    String? albumArtUrl,
    int? durationMs,
  }) {
    return SpotifyTrack(
      uri: uri ?? this.uri,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  List<Object?> get props => [
        uri,
        name,
        artist,
        album,
        albumArtUrl,
        durationMs,
      ];
}
