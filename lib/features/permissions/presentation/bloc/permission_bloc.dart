import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../settings/data/repositories/settings_repository.dart';

part 'permission_event.dart';
part 'permission_state.dart';

/// Manages permission requests and onboarding completion.
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const PermissionState()) {
    on<PermissionLocationRequested>(_onLocationRequested);
    on<PermissionActivityRequested>(_onActivityRequested);
    on<PermissionNotificationRequested>(_onNotificationRequested);
    on<PermissionContinuePressed>(_onContinuePressed);
    on<PermissionNavigationHandled>(_onNavigationHandled);
  }

  final SettingsRepository _settingsRepository;

  Future<void> _onLocationRequested(
    PermissionLocationRequested event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(locationStatus: PermissionRequestStatus.requesting));

    final status = await Permission.locationWhenInUse.request();
    emit(state.copyWith(
      locationStatus: _mapStatus(status),
      locationGranted: status.isGranted,
    ));
  }

  Future<void> _onActivityRequested(
    PermissionActivityRequested event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(activityStatus: PermissionRequestStatus.requesting));

    final status = await Permission.activityRecognition.request();
    emit(state.copyWith(
      activityStatus: _mapStatus(status),
      activityGranted: status.isGranted,
    ));
  }

  Future<void> _onNotificationRequested(
    PermissionNotificationRequested event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(
      notificationStatus: PermissionRequestStatus.requesting,
    ));

    final status = await Permission.notification.request();
    emit(state.copyWith(
      notificationStatus: _mapStatus(status),
      notificationGranted: status.isGranted,
    ));
  }

  Future<void> _onContinuePressed(
    PermissionContinuePressed event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(status: PermissionFlowStatus.completing));

    await _settingsRepository.ensureDefaultSettings();
    await _settingsRepository.updateNotifications(
      enabled: state.notificationGranted,
    );

    emit(state.copyWith(status: PermissionFlowStatus.completed));
  }

  void _onNavigationHandled(
    PermissionNavigationHandled event,
    Emitter<PermissionState> emit,
  ) {
    emit(state.copyWith(status: PermissionFlowStatus.initial));
  }

  PermissionRequestStatus _mapStatus(PermissionStatus status) {
    if (status.isGranted) return PermissionRequestStatus.granted;
    if (status.isPermanentlyDenied) {
      return PermissionRequestStatus.permanentlyDenied;
    }
    return PermissionRequestStatus.denied;
  }
}
