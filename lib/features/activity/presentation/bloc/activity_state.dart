part of 'activity_bloc.dart';

enum ActivityTrackingStatus {
  initial,
  locating,
  ready,
  tracking,
  paused,
  stopped,
}

enum ActivityPermissionStatus {
  unknown,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

enum ActivityWorkoutSaveStatus {
  none,
  saving,
  saved,
  failed,
}

final class ActivityState extends Equatable {
  const ActivityState({
    this.status = ActivityTrackingStatus.initial,
    this.permissionStatus = ActivityPermissionStatus.unknown,
    this.workoutSaveStatus = ActivityWorkoutSaveStatus.none,
    this.currentPosition,
    this.routePoints = const [],
    this.duration = Duration.zero,
    this.distanceMeters = 0,
    this.currentSpeedMps = 0,
    this.averageSpeedMps = 0,
    this.maxSpeedMps = 0,
    this.gpsAccuracyMeters = 0,
    this.currentAltitudeMeters = 0,
    this.activeCalories = 0,
    this.elevationGainMeters = 0,
    this.activityType = 'outdoor_run',
    this.followUser = true,
    this.errorMessage,
    this.pendingCelebration,
    this.savedWorkoutId,
    this.userGender = 'male',
  });

  final ActivityTrackingStatus status;
  final ActivityPermissionStatus permissionStatus;
  final ActivityWorkoutSaveStatus workoutSaveStatus;
  final LatLng? currentPosition;
  final List<LatLng> routePoints;
  final Duration duration;
  final double distanceMeters;
  final double currentSpeedMps;
  final double averageSpeedMps;
  final double maxSpeedMps;
  final double gpsAccuracyMeters;
  final double currentAltitudeMeters;
  final int activeCalories;
  final double elevationGainMeters;
  final String activityType;
  final bool followUser;
  final String? errorMessage;
  final Achievement? pendingCelebration;
  final int? savedWorkoutId;
  final String userGender;

  bool get isSessionActive =>
      status == ActivityTrackingStatus.tracking ||
      status == ActivityTrackingStatus.paused;

  bool get showWorkoutPanel => isSessionActive;

  bool get isHike => activityType.toLowerCase().contains('hike');

  Set<Polyline> get polylines =>
      GradientPolyline.build(routePoints, idPrefix: 'activity_route');

  ActivityState copyWith({
    ActivityTrackingStatus? status,
    ActivityPermissionStatus? permissionStatus,
    ActivityWorkoutSaveStatus? workoutSaveStatus,
    LatLng? currentPosition,
    List<LatLng>? routePoints,
    Duration? duration,
    double? distanceMeters,
    double? currentSpeedMps,
    double? averageSpeedMps,
    double? maxSpeedMps,
    double? gpsAccuracyMeters,
    double? currentAltitudeMeters,
    int? activeCalories,
    double? elevationGainMeters,
    String? activityType,
    bool? followUser,
    String? errorMessage,
    Achievement? pendingCelebration,
    int? savedWorkoutId,
    String? userGender,
    bool clearError = false,
    bool clearPendingCelebration = false,
    bool clearSavedWorkoutId = false,
  }) {
    return ActivityState(
      status: status ?? this.status,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      workoutSaveStatus: workoutSaveStatus ?? this.workoutSaveStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      routePoints: routePoints ?? this.routePoints,
      duration: duration ?? this.duration,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      currentSpeedMps: currentSpeedMps ?? this.currentSpeedMps,
      averageSpeedMps: averageSpeedMps ?? this.averageSpeedMps,
      maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
      gpsAccuracyMeters: gpsAccuracyMeters ?? this.gpsAccuracyMeters,
      currentAltitudeMeters:
          currentAltitudeMeters ?? this.currentAltitudeMeters,
      activeCalories: activeCalories ?? this.activeCalories,
      elevationGainMeters:
          elevationGainMeters ?? this.elevationGainMeters,
      activityType: activityType ?? this.activityType,
      followUser: followUser ?? this.followUser,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingCelebration: clearPendingCelebration
          ? null
          : pendingCelebration ?? this.pendingCelebration,
      savedWorkoutId: clearSavedWorkoutId
          ? null
          : savedWorkoutId ?? this.savedWorkoutId,
      userGender: userGender ?? this.userGender,
    );
  }

  @override
  List<Object?> get props => [
        status,
        permissionStatus,
        workoutSaveStatus,
        currentPosition,
        routePoints,
        duration,
        distanceMeters,
        currentSpeedMps,
        averageSpeedMps,
        maxSpeedMps,
        gpsAccuracyMeters,
        currentAltitudeMeters,
        activeCalories,
        elevationGainMeters,
        activityType,
        followUser,
        errorMessage,
        pendingCelebration,
        savedWorkoutId,
        userGender,
      ];
}
