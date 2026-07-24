part of 'permission_bloc.dart';

sealed class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object?> get props => [];
}

final class PermissionLocationRequested extends PermissionEvent {
  const PermissionLocationRequested();
}

final class PermissionActivityRequested extends PermissionEvent {
  const PermissionActivityRequested();
}

final class PermissionNotificationRequested extends PermissionEvent {
  const PermissionNotificationRequested();
}

final class PermissionContinuePressed extends PermissionEvent {
  const PermissionContinuePressed();
}

final class PermissionNavigationHandled extends PermissionEvent {
  const PermissionNavigationHandled();
}
