import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../services/haptic_service.dart';
import '../services/permission_service.dart';

/// Inline status banner for offline, GPS, and permission recovery states.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tone = StatusBannerTone.warning,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final StatusBannerTone tone;

  factory StatusBanner.gpsUnavailable({VoidCallback? onRetry}) {
    return StatusBanner(
      icon: Icons.gps_off_rounded,
      message: 'GPS signal unavailable. Move to an open area for better accuracy.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  factory StatusBanner.locationDisabled({VoidCallback? onOpenSettings}) {
    return StatusBanner(
      icon: Icons.location_off_rounded,
      message: 'Location services are turned off on this device.',
      actionLabel: 'Open Settings',
      onAction: onOpenSettings ?? PermissionService.openLocationSettings,
      tone: StatusBannerTone.error,
    );
  }

  factory StatusBanner.permissionMissing({
    required bool permanentlyDenied,
    VoidCallback? onOpenSettings,
    VoidCallback? onRetry,
  }) {
    return StatusBanner(
      icon: Icons.location_disabled_rounded,
      message: permanentlyDenied
          ? 'Location permission is blocked. Enable it in Settings to track activities.'
          : 'Location permission is required to track your workout route.',
      actionLabel: permanentlyDenied ? 'Open Settings' : 'Allow Access',
      onAction: permanentlyDenied
          ? (onOpenSettings ?? PermissionService.openAppSettings)
          : onRetry,
      tone: StatusBannerTone.error,
    );
  }

  factory StatusBanner.databaseUnavailable({VoidCallback? onRetry}) {
    return StatusBanner(
      icon: Icons.storage_rounded,
      message: 'Local storage is temporarily unavailable.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
      tone: StatusBannerTone.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      StatusBannerTone.warning => AppColorPalette.warning,
      StatusBannerTone.error => AppColorPalette.error,
      StatusBannerTone.info => AppColorPalette.primaryLight,
    };

    return Semantics(
      liveRegion: true,
      label: message,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColorPalette.darkCard.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColorPalette.grey200,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    HapticService.lightImpact();
                    onAction!();
                  },
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum StatusBannerTone { warning, error, info }
