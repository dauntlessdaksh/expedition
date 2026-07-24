import 'dart:async';
import 'dart:io' show Platform;

import 'spotify_auth_service.dart';
import 'spotify_remote_service.dart';
import 'models/spotify_exception.dart';
import 'models/spotify_player_state.dart';

/// Coordinates Spotify authentication and App Remote playback control.
class SpotifyRepository {
  SpotifyRepository({
    required SpotifyAuthService authService,
    required SpotifyRemoteService remoteService,
  })  : _authService = authService,
        _remoteService = remoteService;

  final SpotifyAuthService _authService;
  final SpotifyRemoteService _remoteService;

  StreamSubscription<SpotifyPlayerState>? _playerStateSubscription;
  StreamController<SpotifyPlayerState>? _playerStateController;

  Future<String?> get accountLabel => _authService.accountLabel;

  Future<bool> hasStoredSession() => _authService.hasStoredSession();

  bool get isRemoteConnected => _remoteService.isConnected;

  /// Connects Spotify App Remote. On Android this uses a single native auth flow.
  Future<void> connect() async {
    if (_remoteService.isConnected) {
      await _startPlayerStateBridge();
      return;
    }

    if (Platform.isAndroid) {
      await _remoteService.connect();
      await _authService.markSessionAuthorized();
      await _startPlayerStateBridge();
      return;
    }

    final restoredToken = await _authService.restoreAccessToken();
    final accessToken =
        restoredToken ?? await _authService.authenticateForPlatform();

    if (accessToken == null) {
      throw const SpotifyException(SpotifyFailureMessages.generic);
    }

    await _remoteService.connect(accessToken: accessToken);
    await _authService.markSessionAuthorized();
    await _startPlayerStateBridge();
  }

  /// Reconnects App Remote using stored credentials without running web OAuth.
  Future<void> reconnectRemote() async {
    if (_remoteService.isConnected) {
      await _startPlayerStateBridge();
      return;
    }

    if (Platform.isAndroid) {
      if (!await hasStoredSession()) {
        throw const SpotifyException(SpotifyFailureMessages.expiredSession);
      }

      await _remoteService.connect();
      await _startPlayerStateBridge();
      return;
    }

    final accessToken = await _authService.restoreAccessToken();
    if (accessToken == null) {
      throw const SpotifyException(SpotifyFailureMessages.expiredSession);
    }

    await _remoteService.connect(accessToken: accessToken);
    await _startPlayerStateBridge();
  }

  Future<bool> restoreSession() async {
    if (!await hasStoredSession()) {
      return false;
    }

    if (_remoteService.isConnected) {
      await _startPlayerStateBridge();
      return true;
    }

    try {
      await reconnectRemote();
      return true;
    } on SpotifyException {
      return false;
    }
  }

  Future<void> disconnect() async {
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await _playerStateController?.close();
    _playerStateController = null;

    await _remoteService.disconnect();
    await _authService.clearSession();
  }

  Future<void> play() => _remoteService.play();

  Future<void> pause() => _remoteService.pause();

  Future<void> next() => _remoteService.next();

  Future<void> previous() => _remoteService.previous();

  Future<void> seek(int positionMs) => _remoteService.seek(positionMs);

  Stream<SpotifyPlayerState> subscribePlayerState() {
    _playerStateController ??=
        StreamController<SpotifyPlayerState>.broadcast(onListen: _ensureBridge);

    return _playerStateController!.stream;
  }

  Future<SpotifyPlayerState> getCurrentPlayerState() =>
      _remoteService.getCurrentPlayerState();

  Future<void> _startPlayerStateBridge() async {
    await _playerStateSubscription?.cancel();
    _playerStateController ??=
        StreamController<SpotifyPlayerState>.broadcast(onListen: _ensureBridge);

    _playerStateSubscription =
        _remoteService.subscribePlayerState().listen((state) {
      _playerStateController?.add(state);
    }, onError: (Object error) {
      _playerStateController?.addError(error);
    });
  }

  void _ensureBridge() {
    if (_playerStateSubscription != null || !_remoteService.isConnected) {
      return;
    }

    unawaited(_startPlayerStateBridge());
  }

  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _playerStateController?.close();
  }
}
