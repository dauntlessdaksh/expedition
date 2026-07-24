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
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String get _formattedDate =>
      DateFormat('EEEE, MMMM d').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          style: const TextStyle(
            color: AppColorPalette.grey400,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          userName,
          style: const TextStyle(
            color: AppColorPalette.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _formattedDate,
          style: const TextStyle(
            color: AppColorPalette.grey500,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorPalette.primary.withValues(alpha: 0.25),
                AppColorPalette.darkCardElevated,
              ],
            ),
            border: Border.all(
              color: AppColorPalette.primary.withValues(alpha: 0.4),
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColorPalette.primaryLight,
            size: 22,
          ),
        ),
      ),
    );
  }
}
