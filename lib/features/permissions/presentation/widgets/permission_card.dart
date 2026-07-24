import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/premium_scaffold.dart';
import '../bloc/permission_bloc.dart';

/// Card explaining and requesting a single permission.
class PermissionCard extends StatelessWidget {
  const PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.isGranted,
    required this.onAllow,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final PermissionRequestStatus status;
  final bool isGranted;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final isRequesting = status == PermissionRequestStatus.requesting;

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColorPalette.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColorPalette.primaryLight, size: 26),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColorPalette.grey400,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isGranted)
            const Icon(
              Icons.check_circle,
              color: AppColorPalette.success,
              size: 28,
            )
          else
            Material(
              color: AppColorPalette.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: isRequesting ? null : onAllow,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 36,
                  child: Center(
                    child: isRequesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColorPalette.primaryLight,
                            ),
                          )
                        : const Text(
                            'Allow',
                            style: TextStyle(
                              color: AppColorPalette.primaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
