import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Time-aware greeting with the user's name and current date.
class GreetingSection extends StatelessWidget {
  const GreetingSection({
    required this.userName,
    super.key,
  });

  final String userName;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _formattedDate =>
      DateFormat('EEEE, MMMM d').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting.toUpperCase(),
          style: const TextStyle(
            color: AppColorPalette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          userName,
          style: const TextStyle(
            color: AppColorPalette.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.05,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _formattedDate,
          style: const TextStyle(
            color: AppColorPalette.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Circular profile button for the top-right header.
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColorPalette.surface,
            border: Border.all(
              color: AppColorPalette.primary.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColorPalette.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
