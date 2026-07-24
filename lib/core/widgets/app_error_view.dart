import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../errors/app_failure.dart';
import '../errors/failure_mapper.dart';
import '../services/haptic_service.dart';
import '../services/permission_service.dart';

/// Centralized error presentation with retry and settings recovery actions.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.failure,
    this.onRetry,
    super.key,
  });

  final AppFailure failure;
  final VoidCallback? onRetry;

  factory AppErrorView.fromError(
    Object error, {
    VoidCallback? onRetry,
    String? fallbackMessage,
  }) {
    return AppErrorView(
      failure: FailureMapper.from(error, fallbackMessage: fallbackMessage),
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${failure.title}. ${failure.message}',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForType(failure.type),
                color: AppColorPalette.error,
                size: 52,
                semanticLabel: 'Error',
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                failure.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                failure.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColorPalette.grey400,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (failure.canRetry && onRetry != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      HapticService.lightImpact();
                      onRetry!();
                    },
                    child: Text(AppStrings.retry),
                  ),
                ),
              if (failure.canOpenSettings) ...[
                if (failure.canRetry && onRetry != null)
                  const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticService.lightImpact();
                      PermissionService.openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(AppFailureType type) {
    return switch (type) {
      AppFailureType.permissionDenied ||
      AppFailureType.permissionPermanentlyDenied =>
        Icons.location_disabled_rounded,
      AppFailureType.gpsUnavailable ||
      AppFailureType.locationTimeout =>
        Icons.gps_off_rounded,
      AppFailureType.locationServiceDisabled => Icons.location_off_rounded,
      AppFailureType.database => Icons.storage_rounded,
      AppFailureType.network => Icons.wifi_off_rounded,
      AppFailureType.unknown => Icons.error_outline_rounded,
    };
  }
}
