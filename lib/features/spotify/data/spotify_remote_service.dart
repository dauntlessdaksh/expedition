import 'dart:async';

import 'package:flutter/services.dart';
import 'package:spotify_sdk/models/player_options.dart' as sdk_options;
import 'package:spotify_sdk/models/player_state.dart' as sdk;
import 'package:spotify_sdk/spotify_sdk.dart';

import '../../../core/constants/spotify_config.dart';
import 'models/spotify_exception.dart';
import 'models/spotify_player_state.dart';
import 'models/spotify_track.dart';

/// Wraps the Spotify App Remote SDK for playback control.
class SpotifyRemoteService {
  StreamSubscription<sdk.PlayerState>? _playerStateSubscription;
  StreamController<SpotifyPlayerState>? _playerStateController;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect({String? accessToken}) async {
    try {
      final connected = await SpotifySdk.connectToSpotifyRemote(
        clientId: SpotifyConfig.clientId,
        redirectUrl: SpotifyConfig.redirectUri,
        accessToken: accessToken,
      );

      if (!connected) {
        throw const SpotifyException(SpotifyFailureMessages.remoteDisconnected);
      }

      _isConnected = true;
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    } on MissingPluginException {
      throw const SpotifyException(SpotifyFailureMessages.generic);
    }
  }

  Future<void> disconnect() async {
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await _playerStateController?.close();
    _playerStateController = null;

    try {
      await SpotifySdk.disconnect();
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    } finally {
      _isConnected = false;
    }
  }

  Stream<SpotifyPlayerState> subscribePlayerState() {
    _playerStateController?.close();
    _playerStateController = StreamController<SpotifyPlayerState>.broadcast();

    _playerStateSubscription?.cancel();
    _playerStateSubscription = SpotifySdk.subscribePlayerState().listen(
      (state) {
        _playerStateController?.add(_mapPlayerState(state));
      },
      onError: (Object error) {
        _playerStateController?.addError(error);
      },
    );

    unawaited(_emitCurrentState());

    return _playerStateController!.stream;
  }

  Future<SpotifyPlayerState> getCurrentPlayerState() async {
    try {
      final state = await SpotifySdk.getPlayerState();
      if (state == null) {
        return const SpotifyPlayerState();
      }
      return _mapPlayerState(state);
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    }
  }

  Future<void> play() => _resume();

  Future<void> pause() async {
    await _invoke(() => SpotifySdk.pause());
  }

  Future<void> resume() => _resume();

  Future<void> next() async {
    await _invoke(() => SpotifySdk.skipNext());
  }

  Future<void> previous() async {
    await _invoke(() => SpotifySdk.skipPrevious());
  }

  Future<void> seek(int positionMs) async {
    await _invoke(() => SpotifySdk.seekTo(positionedMilliseconds: positionMs));
  }

  Future<void> _resume() async {
    await _invoke(() => SpotifySdk.resume());
  }

  Future<void> _emitCurrentState() async {
    try {
      final state = await getCurrentPlayerState();
      _playerStateController?.add(state);
    } on SpotifyException {
      // Ignore initial fetch failures; stream updates will arrive later.
    }
  }

  Future<void> _invoke(Future<void> Function() action) async {
    try {
      await action();
    } on PlatformException catch (error) {
      throw _mapPlatformException(error);
    }
  }

  SpotifyPlayerState _mapPlayerState(sdk.PlayerState state) {
    final track = state.track;
    final mappedTrack = track == null
        ? null
        : SpotifyTrack(
            uri: track.uri,
            name: track.name,
            artist: track.artist.name ?? track.artists.firstOrNull?.name ?? '',
            album: track.album.name ?? '',
            albumArtUrl: track.imageUri.raw,
            durationMs: track.duration,
          );

    return SpotifyPlayerState(
      track: mappedTrack,
      isPlaying: !state.isPaused,
      positionMs: state.playbackPosition,
      durationMs: mappedTrack?.durationMs ?? 0,
      isShuffleEnabled: state.playbackOptions.isShuffling,
      repeatMode: _mapRepeatMode(state.playbackOptions.repeatMode),
    );
  }

  SpotifyRepeatMode _mapRepeatMode(sdk_options.RepeatMode mode) {
    return switch (mode) {
      sdk_options.RepeatMode.track => SpotifyRepeatMode.track,
      sdk_options.RepeatMode.context => SpotifyRepeatMode.context,
      sdk_options.RepeatMode.off => SpotifyRepeatMode.off,
    };
  }

  SpotifyException _mapPlatformException(PlatformException error) {
    final message = (error.message ?? '').toLowerCase();
    final code = error.code.toLowerCase();

    if (code.contains('not_installed') ||
        message.contains('not installed') ||
        message.contains('spotify app')) {
      return const SpotifyException(SpotifyFailureMessages.notInstalled);
    }

    if (code.contains('cancel') || message.contains('cancel')) {
      return const SpotifyException(SpotifyFailureMessages.authCancelled);
    }

    if (code.contains('not_logged_in') ||
        message.contains('not logged in') ||
        message.contains('authentication')) {
      return const SpotifyException(SpotifyFailureMessages.expiredSession);
    }

    if (message.contains('connection') || code.contains('connection')) {
      return const SpotifyException(SpotifyFailureMessages.remoteDisconnected);
    }

    return SpotifyException(
      error.message ?? SpotifyFailureMessages.generic,
      code: error.code,
    );
  }
}
