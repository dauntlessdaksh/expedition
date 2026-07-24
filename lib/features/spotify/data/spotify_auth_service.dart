import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../../core/constants/spotify_config.dart';
import '../../../../core/utils/logger.dart';
import 'models/spotify_exception.dart';

/// Handles Spotify OAuth (PKCE) and secure token persistence.
class SpotifyAuthService {
  SpotifyAuthService({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const _accessTokenKey = 'spotify_access_token';
  static const _refreshTokenKey = 'spotify_refresh_token';
  static const _expiresAtKey = 'spotify_expires_at';
  static const _accountLabelKey = 'spotify_account_label';
  static const _sessionAuthorizedKey = 'spotify_session_authorized';

  Future<String?> get accountLabel =>
      _secureStorage.read(key: _accountLabelKey);

  Future<bool> hasStoredSession() async {
    final authorized = await _secureStorage.read(key: _sessionAuthorizedKey);
    if (authorized == 'true') {
      return true;
    }

    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    return (refreshToken != null && refreshToken.isNotEmpty) ||
        (accessToken != null && accessToken.isNotEmpty);
  }

  Future<void> markSessionAuthorized() async {
    await _secureStorage.write(key: _sessionAuthorizedKey, value: 'true');
  }

  /// Android App Remote uses the Spotify SDK auth flow (single native prompt).
  /// iOS uses PKCE via flutter_web_auth_2, then passes the token to App Remote.
  Future<String?> authenticateForPlatform() async {
    if (Platform.isAndroid) {
      return null;
    }

    return authenticateWithWebAuth();
  }

  Future<String> authenticateWithWebAuth() async {
    final verifier = _generateCodeVerifier();
    final challenge = _codeChallenge(verifier);
    final state = _generateCodeVerifier(length: 16);

    final authUri = Uri.parse(SpotifyConfig.authorizationEndpoint).replace(
      queryParameters: {
        'client_id': SpotifyConfig.clientId,
        'response_type': 'code',
        'redirect_uri': SpotifyConfig.redirectUri,
        'scope': SpotifyConfig.scopes,
        'code_challenge_method': 'S256',
        'code_challenge': challenge,
        'state': state,
      },
    );

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: SpotifyConfig.redirectScheme,
      );

      final callbackUri = Uri.parse(result);
      if (callbackUri.queryParameters['error'] != null) {
        throw SpotifyException(
          callbackUri.queryParameters['error_description'] ??
              SpotifyFailureMessages.generic,
          code: callbackUri.queryParameters['error'],
        );
      }

      final returnedState = callbackUri.queryParameters['state'];
      if (returnedState != state) {
        throw const SpotifyException(SpotifyFailureMessages.generic);
      }

      final code = callbackUri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        throw const SpotifyException(SpotifyFailureMessages.authCancelled);
      }

      return _exchangeAuthorizationCode(code: code, verifier: verifier);
    } on SpotifyException {
      rethrow;
    } on Exception catch (error) {
      if (error.toString().toLowerCase().contains('cancel')) {
        throw const SpotifyException(SpotifyFailureMessages.authCancelled);
      }
      throw SpotifyException(
        SpotifyFailureMessages.network,
        code: error.toString(),
      );
    }
  }

  Future<String?> restoreAccessToken() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final expiresAtRaw = await _secureStorage.read(key: _expiresAtKey);
    final expiresAt = int.tryParse(expiresAtRaw ?? '');

    if (accessToken != null &&
        accessToken.isNotEmpty &&
        expiresAt != null &&
        DateTime.now().millisecondsSinceEpoch < expiresAt - 60000) {
      return accessToken;
    }

    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      return await _refreshAccessToken(refreshToken);
    } on SpotifyException {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
    await _secureStorage.delete(key: _accountLabelKey);
    await _secureStorage.delete(key: _sessionAuthorizedKey);
  }

  Future<String> _exchangeAuthorizationCode({
    required String code,
    required String verifier,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        SpotifyConfig.tokenEndpoint,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': SpotifyConfig.redirectUri,
          'client_id': SpotifyConfig.clientId,
          'code_verifier': verifier,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      final payload = response.data;
      if (payload == null) {
        throw const SpotifyException(SpotifyFailureMessages.generic);
      }

      await _persistTokenPayload(payload);
      await _cacheAccountLabel(payload['access_token'] as String? ?? '');

      final accessToken = payload['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw const SpotifyException(SpotifyFailureMessages.generic);
      }

      return accessToken;
    } on DioException {
      throw const SpotifyException(SpotifyFailureMessages.network);
    }
  }

  Future<String> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        SpotifyConfig.tokenEndpoint,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': SpotifyConfig.clientId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      final payload = response.data;
      if (payload == null) {
        throw const SpotifyException(SpotifyFailureMessages.expiredSession);
      }

      await _persistTokenPayload(
        payload,
        fallbackRefreshToken: refreshToken,
      );

      final accessToken = payload['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw const SpotifyException(SpotifyFailureMessages.expiredSession);
      }

      return accessToken;
    } on DioException {
      throw const SpotifyException(SpotifyFailureMessages.network);
    }
  }

  Future<void> _persistTokenPayload(
    Map<String, dynamic> payload, {
    String? fallbackRefreshToken,
  }) async {
    final accessToken = payload['access_token'] as String?;
    final refreshToken =
        payload['refresh_token'] as String? ?? fallbackRefreshToken;
    final expiresIn = payload['expires_in'] as int? ?? 3600;

    if (accessToken == null || accessToken.isEmpty) {
      throw const SpotifyException(SpotifyFailureMessages.generic);
    }

    final expiresAt =
        DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;

    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _expiresAtKey, value: '$expiresAt');

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> _cacheAccountLabel(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        SpotifyConfig.profileEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          responseType: ResponseType.json,
        ),
      );

      final displayName = response.data?['display_name'] as String?;
      final email = response.data?['email'] as String?;
      final label = (displayName != null && displayName.isNotEmpty)
          ? displayName
          : email;

      if (label != null && label.isNotEmpty) {
        await _secureStorage.write(key: _accountLabelKey, value: label);
      }
    } on Exception catch (error) {
      AppLogger.debug('Unable to cache Spotify profile label: $error');
    }
  }

  String _generateCodeVerifier({int length = 64}) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _codeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier)).bytes;
    return base64Url.encode(digest).replaceAll('=', '');
  }
}
