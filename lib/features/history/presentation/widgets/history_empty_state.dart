import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Empty state shown when no workouts match the current history query.
class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
    this.showAction = true,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onActionPressed;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorPalette.primary.withValues(alpha: 0.22),
                    AppColorPalette.darkCard,
                  ],
                ),
                border: Border.all(
                  color: AppColorPalette.primary.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.route_rounded,
                color: AppColorPalette.primaryLight,
                size: 52,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColorPalette.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: PremiumGradients.accentButton,
                    borderRadius: AppBorderRadius.radiusLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColorPalette.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onActionPressed,
                      borderRadius: AppBorderRadius.radiusLg,
                      child: Center(
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: AppColorPalette.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
