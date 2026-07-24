import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/spotify_exception.dart';
import '../../data/models/spotify_player_state.dart';
import '../../data/models/spotify_track.dart';
import '../../data/spotify_repository.dart';

part 'spotify_event.dart';
part 'spotify_state.dart';

/// Manages Spotify authentication, remote playback, and player state.
class SpotifyBloc extends Bloc<SpotifyEvent, SpotifyState> {
  SpotifyBloc({required SpotifyRepository repository})
      : _repository = repository,
        super(const SpotifyState()) {
    on<ConnectSpotify>(_onConnect);
    on<DisconnectSpotify>(_onDisconnect);
    on<RestoreSpotifySession>(_onRestore);
    on<EnsureSpotifyRemoteConnected>(_onEnsureRemoteConnected);
    on<PlayPressed>(_onPlay);
    on<PausePressed>(_onPause);
    on<NextPressed>(_onNext);
    on<PreviousPressed>(_onPrevious);
    on<SeekChanged>(_onSeek);
    on<PlayerStateUpdated>(_onPlayerStateUpdated);
    on<_PlayerStateStreamFailed>(_onPlayerStateStreamFailed);
    on<_PlaybackTicked>(_onPlaybackTicked);
  }

  final SpotifyRepository _repository;
  StreamSubscription<SpotifyPlayerState>? _playerStateSubscription;
  Timer? _playbackTimer;

  Future<void> _onConnect(
    ConnectSpotify event,
    Emitter<SpotifyState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    if (state.isConnected) {
      return;
    }

    emit(state.copyWith(
      status: SpotifyStatus.loading,
      clearError: true,
    ));

    try {
      await _repository.connect();
      await _emitConnectedState(emit);
    } on SpotifyException catch (error) {
      final authenticated = await _repository.hasStoredSession();
      emit(state.copyWith(
        status: authenticated
            ? SpotifyStatus.disconnected
            : SpotifyStatus.error,
        isAuthenticated: authenticated,
        errorMessage: error.message,
      ));
    } on Exception {
      emit(state.copyWith(
        status: SpotifyStatus.error,
        errorMessage: SpotifyFailureMessages.generic,
      ));
    }
  }

  Future<void> _onEnsureRemoteConnected(
    EnsureSpotifyRemoteConnected event,
    Emitter<SpotifyState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    if (state.isConnected) {
      return;
    }

    if (!state.isAuthenticated && !await _repository.hasStoredSession()) {
      add(const ConnectSpotify());
      return;
    }

    emit(state.copyWith(
      status: SpotifyStatus.loading,
      isAuthenticated: true,
      clearError: true,
    ));

    try {
      await _repository.reconnectRemote();
      await _emitConnectedState(emit);
    } on SpotifyException catch (error) {
      emit(state.copyWith(
        status: SpotifyStatus.disconnected,
        isAuthenticated: true,
        errorMessage: error.message,
      ));
    } on Exception {
      emit(state.copyWith(
        status: SpotifyStatus.disconnected,
        isAuthenticated: true,
        errorMessage: SpotifyFailureMessages.generic,
      ));
    }
  }

  Future<void> _onDisconnect(
    DisconnectSpotify event,
    Emitter<SpotifyState> emit,
  ) async {
    await _stopListening();
    await _repository.disconnect();
    emit(const SpotifyState(status: SpotifyStatus.disconnected));
  }

  Future<void> _onRestore(
    RestoreSpotifySession event,
    Emitter<SpotifyState> emit,
  ) async {
    if (state.isConnected || state.isLoading) {
      return;
    }

    final hasSession = await _repository.hasStoredSession();
    if (!hasSession) {
      emit(const SpotifyState(status: SpotifyStatus.disconnected));
      return;
    }

    emit(state.copyWith(
      status: SpotifyStatus.loading,
      isAuthenticated: true,
      clearError: true,
    ));

    try {
      final restored = await _repository.restoreSession();
      if (!restored) {
        emit(state.copyWith(
          status: SpotifyStatus.disconnected,
          isAuthenticated: true,
        ));
        return;
      }

      await _emitConnectedState(emit);
    } on SpotifyException catch (error) {
      emit(state.copyWith(
        status: SpotifyStatus.disconnected,
        isAuthenticated: true,
        errorMessage: error.message,
      ));
    } on Exception {
      emit(state.copyWith(
        status: SpotifyStatus.disconnected,
        isAuthenticated: true,
      ));
    }
  }

  Future<void> _emitConnectedState(Emitter<SpotifyState> emit) async {
    final accountLabel = await _repository.accountLabel;
    await _listenToPlayerState();
    final current = await _repository.getCurrentPlayerState();

    emit(_mapPlayerState(
      current,
      status: SpotifyStatus.connected,
      isAuthenticated: true,
      accountLabel: accountLabel,
    ));
    _syncPlaybackTimer(current.isPlaying);
  }

  Future<void> _onPlay(
    PlayPressed event,
    Emitter<SpotifyState> emit,
  ) async {
    await _runControl(() => _repository.play());
  }

  Future<void> _onPause(
    PausePressed event,
    Emitter<SpotifyState> emit,
  ) async {
    await _runControl(() => _repository.pause());
  }

  Future<void> _onNext(
    NextPressed event,
    Emitter<SpotifyState> emit,
  ) async {
    await _runControl(() => _repository.next());
  }

  Future<void> _onPrevious(
    PreviousPressed event,
    Emitter<SpotifyState> emit,
  ) async {
    await _runControl(() => _repository.previous());
  }

  Future<void> _onSeek(
    SeekChanged event,
    Emitter<SpotifyState> emit,
  ) async {
    emit(state.copyWith(positionMs: event.positionMs));
    await _runControl(() => _repository.seek(event.positionMs));
  }

  void _onPlayerStateUpdated(
    PlayerStateUpdated event,
    Emitter<SpotifyState> emit,
  ) {
    emit(_mapPlayerState(
      event.playerState,
      status: SpotifyStatus.connected,
      isAuthenticated: true,
      accountLabel: state.accountLabel,
    ));
    _syncPlaybackTimer(event.playerState.isPlaying);
  }

  void _onPlayerStateStreamFailed(
    _PlayerStateStreamFailed event,
    Emitter<SpotifyState> emit,
  ) {
    emit(state.copyWith(
      status: SpotifyStatus.disconnected,
      isAuthenticated: state.isAuthenticated,
      errorMessage: event.message,
    ));
    _syncPlaybackTimer(false);
  }

  void _onPlaybackTicked(
    _PlaybackTicked event,
    Emitter<SpotifyState> emit,
  ) {
    if (!state.isPlaying || state.durationMs <= 0) {
      return;
    }

    final nextPosition = (state.positionMs + 1000).clamp(0, state.durationMs);
    emit(state.copyWith(positionMs: nextPosition));
  }

  Future<void> _runControl(Future<void> Function() action) async {
    if (!state.isConnected) {
      if (state.isAuthenticated) {
        add(const EnsureSpotifyRemoteConnected());
      }
      return;
    }

    try {
      await action();
    } on SpotifyException catch (error) {
      add(_PlayerStateStreamFailed(error.message));
    } on Exception {
      add(const _PlayerStateStreamFailed(SpotifyFailureMessages.generic));
    }
  }

  Future<void> _listenToPlayerState() async {
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = _repository.subscribePlayerState().listen(
      (playerState) => add(PlayerStateUpdated(playerState)),
      onError: (Object error) {
        final message = error is SpotifyException
            ? error.message
            : SpotifyFailureMessages.remoteDisconnected;
        add(_PlayerStateStreamFailed(message));
      },
    );
  }

  Future<void> _stopListening() async {
    _syncPlaybackTimer(false);
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
  }

  void _syncPlaybackTimer(bool isPlaying) {
    _playbackTimer?.cancel();
    if (!isPlaying) {
      return;
    }

    _playbackTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _PlaybackTicked()),
    );
  }

  SpotifyState _mapPlayerState(
    SpotifyPlayerState playerState, {
    required SpotifyStatus status,
    required bool isAuthenticated,
    String? accountLabel,
  }) {
    return SpotifyState(
      status: status,
      isAuthenticated: isAuthenticated,
      track: playerState.track,
      isPlaying: playerState.isPlaying,
      positionMs: playerState.positionMs,
      durationMs: playerState.durationMs > 0
          ? playerState.durationMs
          : playerState.track?.durationMs ?? 0,
      isShuffleEnabled: playerState.isShuffleEnabled,
      repeatMode: playerState.repeatMode,
      accountLabel: accountLabel,
    );
  }

  @override
  Future<void> close() async {
    await _stopListening();
    await _repository.dispose();
    return super.close();
  }
}
