import '../gps_engine_config.dart';

/// Prevents duplicate or overly frequent GPS processing.
class TimeFilter {
  DateTime? _lastProcessedAt;

  void reset() {
    _lastProcessedAt = null;
  }

  bool passes(DateTime timestamp, GpsEngineConfig config) {
    if (_lastProcessedAt == null) {
      return true;
    }

    return timestamp.difference(_lastProcessedAt!) >=
        config.minimumUpdateInterval;
  }

  void markProcessed(DateTime timestamp) {
    _lastProcessedAt = timestamp;
  }
}
