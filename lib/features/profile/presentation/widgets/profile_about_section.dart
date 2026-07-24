import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import 'profile_section_card.dart';

/// App metadata and legal links.
class ProfileAboutSection extends StatelessWidget {
  const ProfileAboutSection({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'About',
      subtitle: 'Expedition app information',
      child: Column(
        children: [
          _AboutTile(
            label: 'Version',
            value: _appVersion,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AboutTile(
            label: 'Developer',
            value: 'Expedition Team',
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileActionButton(
            label: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onPressed: () => _showPlaceholder(context, 'Privacy Policy'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileActionButton(
            label: 'Terms of Service',
            icon: Icons.description_outlined,
            onPressed: () => _showPlaceholder(context, 'Terms of Service'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileActionButton(
            label: 'Open Source Licenses',
            icon: Icons.code_rounded,
            onPressed: () => showLicensePage(
              context: context,
              applicationName: AppStrings.appName,
              applicationVersion: _appVersion,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title will be available soon.')),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: AppColorPalette.grey700.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
