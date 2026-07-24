part of 'spotify_bloc.dart';

enum SpotifyStatus {
  initial,
  loading,
  connected,
  disconnected,
  error,
}

class SpotifyState extends Equatable {
  const SpotifyState({
    this.status = SpotifyStatus.initial,
    this.isAuthenticated = false,
    this.track,
    this.isPlaying = false,
    this.positionMs = 0,
    this.durationMs = 0,
    this.isShuffleEnabled = false,
    this.repeatMode = SpotifyRepeatMode.off,
    this.accountLabel,
    this.errorMessage,
  });

  final SpotifyStatus status;
  final bool isAuthenticated;
  final SpotifyTrack? track;
  final bool isPlaying;
  final int positionMs;
  final int durationMs;
  final bool isShuffleEnabled;
  final SpotifyRepeatMode repeatMode;
  final String? accountLabel;
  final String? errorMessage;

  bool get isConnected => status == SpotifyStatus.connected;
  bool get isLoading => status == SpotifyStatus.loading;
  bool get hasTrack => track != null && track!.hasMetadata;

  bool get isLinked => isAuthenticated || isConnected;

  SpotifyState copyWith({
    SpotifyStatus? status,
    bool? isAuthenticated,
    SpotifyTrack? track,
    bool? isPlaying,
    int? positionMs,
    int? durationMs,
    bool? isShuffleEnabled,
    SpotifyRepeatMode? repeatMode,
    String? accountLabel,
    String? errorMessage,
    bool clearTrack = false,
    bool clearError = false,
  }) {
    return SpotifyState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      track: clearTrack ? null : track ?? this.track,
      isPlaying: isPlaying ?? this.isPlaying,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      accountLabel: accountLabel ?? this.accountLabel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isAuthenticated,
        track,
        isPlaying,
        positionMs,
        durationMs,
        isShuffleEnabled,
        repeatMode,
        accountLabel,
        errorMessage,
      ];
}
