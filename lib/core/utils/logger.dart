import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight logger for development and debugging.
abstract final class AppLogger {
  static const String _name = 'Expedition';

  /// Logs an informational message.
  static void info(String message, {Object? data}) {
    _log('INFO', message, data: data);
  }

  /// Logs a warning message.
  static void warning(String message, {Object? data}) {
    _log('WARNING', message, data: data);
  }

  /// Logs an error message with optional stack trace.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log('ERROR', message, data: error);
    if (stackTrace != null && kDebugMode) {
      developer.log(
        stackTrace.toString(),
        name: _name,
        level: 1000,
      );
    }
  }

  /// Logs a debug message (only in debug mode).
  static void debug(String message, {Object? data}) {
    if (kDebugMode) {
      _log('DEBUG', message, data: data);
    }
  }

  static void _log(String level, String message, {Object? data}) {
    final buffer = StringBuffer('[$level] $message');
    if (data != null) {
      buffer.write(' | $data');
    }
    developer.log(buffer.toString(), name: _name);
  }
}
