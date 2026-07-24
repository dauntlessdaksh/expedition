/// User-facing Spotify integration failures.
class SpotifyException implements Exception {
  const SpotifyException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'SpotifyException($code): $message';
}

abstract final class SpotifyFailureMessages {
  static const notInstalled =
      'Spotify is not installed. Install Spotify to control playback from Expedition.';

  static const authCancelled = 'Spotify sign-in was cancelled.';

  static const network =
      'Unable to reach Spotify. Check your connection and try again.';

  static const expiredSession =
      'Your Spotify session expired. Connect again to continue.';

  static const remoteDisconnected =
      'Lost connection to Spotify. Open Spotify and try again.';

  static const generic = 'Something went wrong with Spotify. Please try again.';
}
