/// Formats Spotify playback timestamps for UI labels.
abstract final class SpotifyFormatters {
  static String duration(int milliseconds) {
    if (milliseconds <= 0) {
      return '0:00';
    }

    final totalSeconds = (milliseconds / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
