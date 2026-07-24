import '../../../history/domain/models/workout_pace_sample.dart';
import '../../../history/domain/models/workout_split.dart';

/// Records pace samples and kilometer splits during a live workout session.
class WorkoutTelemetryRecorder {
  static const _sampleIntervalSeconds = 10;

  final List<WorkoutPaceSample> paceSamples = [];
  final List<WorkoutSplit> splits = [];

  int _completedKm = 0;
  int _splitStartElapsedSeconds = 0;
  double _splitStartDistanceMeters = 0;
  double _splitStartCalories = 0;
  double _splitStartElevationGain = 0;
  double _splitStartElevationLoss = 0;
  int _lastSampleElapsedSeconds = -_sampleIntervalSeconds;
  double _gpsAccuracySum = 0;
  int _gpsAccuracyCount = 0;

  void reset() {
    paceSamples.clear();
    splits.clear();
    _completedKm = 0;
    _splitStartElapsedSeconds = 0;
    _splitStartDistanceMeters = 0;
    _splitStartCalories = 0;
    _splitStartElevationGain = 0;
    _splitStartElevationLoss = 0;
    _lastSampleElapsedSeconds = -_sampleIntervalSeconds;
    _gpsAccuracySum = 0;
    _gpsAccuracyCount = 0;
  }

  double get averageGpsAccuracyMeters =>
      _gpsAccuracyCount == 0 ? 0 : _gpsAccuracySum / _gpsAccuracyCount;

  void record({
    required int elapsedSeconds,
    required double distanceMeters,
    required double currentSpeedMps,
    required int activeCalories,
    required double elevationGainMeters,
    required double elevationLossMeters,
    required double gpsAccuracyMeters,
    required DateTime timestamp,
  }) {
    if (gpsAccuracyMeters > 0) {
      _gpsAccuracySum += gpsAccuracyMeters;
      _gpsAccuracyCount++;
    }

    if (elapsedSeconds - _lastSampleElapsedSeconds >= _sampleIntervalSeconds) {
      _lastSampleElapsedSeconds = elapsedSeconds;
      final pace = currentSpeedMps > 0.3 ? 1000 / currentSpeedMps : 0.0;
      paceSamples.add(
        WorkoutPaceSample(
          elapsedTimeSeconds: elapsedSeconds,
          paceSecondsPerKm: pace,
          speedMps: currentSpeedMps,
          distanceMeters: distanceMeters,
          timestamp: timestamp,
        ),
      );
    }

    final completedKm = (distanceMeters / 1000).floor();
    while (_completedKm < completedKm) {
      _completedKm++;
      final splitTime = elapsedSeconds - _splitStartElapsedSeconds;
      final splitDistance = distanceMeters - _splitStartDistanceMeters;
      final pace = splitTime > 0 && splitDistance > 0
          ? splitTime / (splitDistance / 1000)
          : 0.0;
      final speed = splitTime > 0 ? splitDistance / splitTime : 0.0;

      splits.add(
        WorkoutSplit(
          splitIndex: _completedKm,
          distanceMeters: 1000,
          splitTimeSeconds: splitTime,
          averagePaceSecondsPerKm: pace,
          averageSpeedMps: speed,
          calories: (activeCalories - _splitStartCalories).round().clamp(0, 99999),
          elevationGainMeters:
              elevationGainMeters - _splitStartElevationGain,
          elevationLossMeters:
              elevationLossMeters - _splitStartElevationLoss,
        ),
      );

      _splitStartElapsedSeconds = elapsedSeconds;
      _splitStartDistanceMeters = distanceMeters;
      _splitStartCalories = activeCalories.toDouble();
      _splitStartElevationGain = elevationGainMeters;
      _splitStartElevationLoss = elevationLossMeters;
    }
  }
}
