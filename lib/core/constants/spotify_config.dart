/// Spotify OAuth and App Remote configuration for Expedition.
///
/// Register the redirect URI in the Spotify Developer Dashboard:
/// `expedition://callback`
///
/// Android package: `com.expedition.expedition`
abstract final class SpotifyConfig {
  static const clientId = '1345f90fcb934c269d09147624343ae3';

  /// Must match the Redirect URI configured in the Spotify Developer Dashboard.
  static const redirectUri = 'expedition://callback';

  static const redirectScheme = 'expedition';

  static const scopes =
      'app-remote-control,user-modify-playback-state,user-read-playback-state,user-read-currently-playing';

  static const authorizationEndpoint =
      'https://accounts.spotify.com/authorize';

  static const tokenEndpoint = 'https://accounts.spotify.com/api/token';

  static const profileEndpoint = 'https://api.spotify.com/v1/me';
}
