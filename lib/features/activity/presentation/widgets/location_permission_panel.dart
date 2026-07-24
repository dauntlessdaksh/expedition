import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../bloc/activity_bloc.dart';

/// Full-width permission recovery panel shown when GPS access is blocked.
class LocationPermissionPanel extends StatelessWidget {
  const LocationPermissionPanel({
    required this.permissionStatus,
    required this.onRetry,
    super.key,
  });

  final ActivityPermissionStatus permissionStatus;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final permanentlyDenied =
        permissionStatus == ActivityPermissionStatus.deniedForever;
    final serviceDisabled =
        permissionStatus == ActivityPermissionStatus.serviceDisabled;

    final title = serviceDisabled
        ? 'Turn on location services'
        : permanentlyDenied
            ? 'Location access blocked'
            : 'Location permission needed';

    final description = serviceDisabled
        ? 'Expedition uses GPS to map your route, distance, and pace during outdoor activities.'
        : permanentlyDenied
            ? 'Location was permanently denied. Open Settings and allow location access for Expedition.'
            : 'Allow location access so Expedition can track your workout route and metrics offline.';

    return Semantics(
      container: true,
      label: title,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: PremiumGradients.cardShimmer,
          borderRadius: AppBorderRadius.radiusXl,
          border: Border.all(
            color: AppColorPalette.warning.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColorPalette.primaryLight,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: const TextStyle(
                color: AppColorPalette.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: const TextStyle(
                color: AppColorPalette.grey400,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                if (!permanentlyDenied)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRetry,
                      child: const Text('Try Again'),
                    ),
                  ),
                if (!permanentlyDenied) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (serviceDisabled) {
                        PermissionService.openLocationSettings();
                      } else {
                        PermissionService.openAppSettings();
                      }
                    },
                    child: const Text('Open Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
