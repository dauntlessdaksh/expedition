part of 'spotify_bloc.dart';

sealed class SpotifyEvent extends Equatable {
  const SpotifyEvent();

  @override
  List<Object?> get props => [];
}

final class ConnectSpotify extends SpotifyEvent {
  const ConnectSpotify();
}

final class DisconnectSpotify extends SpotifyEvent {
  const DisconnectSpotify();
}

final class RestoreSpotifySession extends SpotifyEvent {
  const RestoreSpotifySession();
}

final class EnsureSpotifyRemoteConnected extends SpotifyEvent {
  const EnsureSpotifyRemoteConnected();
}

final class PlayPressed extends SpotifyEvent {
  const PlayPressed();
}

final class PausePressed extends SpotifyEvent {
  const PausePressed();
}

final class NextPressed extends SpotifyEvent {
  const NextPressed();
}

final class PreviousPressed extends SpotifyEvent {
  const PreviousPressed();
}

final class SeekChanged extends SpotifyEvent {
  const SeekChanged(this.positionMs);

  final int positionMs;

  @override
  List<Object?> get props => [positionMs];
}

final class PlayerStateUpdated extends SpotifyEvent {
  const PlayerStateUpdated(this.playerState);

  final SpotifyPlayerState playerState;

  @override
  List<Object?> get props => [playerState];
}

final class _PlayerStateStreamFailed extends SpotifyEvent {
  const _PlayerStateStreamFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class _PlaybackTicked extends SpotifyEvent {
  const _PlaybackTicked();
}
