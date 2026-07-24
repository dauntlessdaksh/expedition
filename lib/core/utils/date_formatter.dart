import 'package:intl/intl.dart';

/// Utility class for consistent date and time formatting across the app.
abstract final class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy · h:mm a');
  static final DateFormat _shortDateFormat = DateFormat('MM/dd/yy');

  /// Formats a [DateTime] as "Jan 1, 2025".
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Formats a [DateTime] as "3:30 PM".
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Formats a [DateTime] as "Jan 1, 2025 · 3:30 PM".
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Formats a [DateTime] as "01/01/25".
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Formats a [Duration] as "01:23:45".
  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes =
        (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds =
        (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Formats a [Duration] as a human-readable string, e.g. "1h 23m".
  static String formatDurationShort(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m';
    }
    return '${duration.inSeconds}s';
  }
}
