part of 'permission_bloc.dart';

enum PermissionRequestStatus {
  initial,
  requesting,
  granted,
  denied,
  permanentlyDenied,
}

enum PermissionFlowStatus {
  initial,
  completing,
  completed,
}

final class PermissionState extends Equatable {
  const PermissionState({
    this.locationStatus = PermissionRequestStatus.initial,
    this.activityStatus = PermissionRequestStatus.initial,
    this.notificationStatus = PermissionRequestStatus.initial,
    this.locationGranted = false,
    this.activityGranted = false,
    this.notificationGranted = false,
    this.status = PermissionFlowStatus.initial,
  });

  final PermissionRequestStatus locationStatus;
  final PermissionRequestStatus activityStatus;
  final PermissionRequestStatus notificationStatus;
  final bool locationGranted;
  final bool activityGranted;
  final bool notificationGranted;
  final PermissionFlowStatus status;

  PermissionState copyWith({
    PermissionRequestStatus? locationStatus,
    PermissionRequestStatus? activityStatus,
    PermissionRequestStatus? notificationStatus,
    bool? locationGranted,
    bool? activityGranted,
    bool? notificationGranted,
    PermissionFlowStatus? status,
  }) {
    return PermissionState(
      locationStatus: locationStatus ?? this.locationStatus,
      activityStatus: activityStatus ?? this.activityStatus,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      locationGranted: locationGranted ?? this.locationGranted,
      activityGranted: activityGranted ?? this.activityGranted,
      notificationGranted: notificationGranted ?? this.notificationGranted,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        locationStatus,
        activityStatus,
        notificationStatus,
        locationGranted,
        activityGranted,
        notificationGranted,
        status,
      ];
}
