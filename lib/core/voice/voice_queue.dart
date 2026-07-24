import 'dart:async';
import 'dart:collection';

/// Serializes voice announcements so only one plays at a time.
class VoiceQueue {
  VoiceQueue();

  final Queue<String> _pending = Queue<String>();
  Future<void> Function(String text)? _speak;
  bool _isProcessing = false;
  bool _disposed = false;

  set speakHandler(Future<void> Function(String text) handler) {
    _speak = handler;
  }

  int get pendingCount => _pending.length;

  bool get isProcessing => _isProcessing;

  /// Adds [text] to the queue and begins playback if idle.
  Future<void> enqueue(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _disposed) {
      return Future<void>.value();
    }

    _pending.add(trimmed);
    return _processQueue();
  }

  /// Clears pending announcements without stopping the current utterance.
  void clearPending() {
    _pending.clear();
  }

  /// Clears the queue and stops further processing until re-enabled.
  void dispose() {
    _disposed = true;
    _pending.clear();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _disposed || _speak == null) {
      return;
    }

    _isProcessing = true;
    while (_pending.isNotEmpty && !_disposed) {
      final next = _pending.removeFirst();
      try {
        await _speak!(next);
      } on Object {
        // Continue with remaining announcements even if one fails.
      }
    }
    _isProcessing = false;
  }
}
