import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/haptic_service.dart';
import '../bloc/profile_bloc.dart';
import 'profile_section_card.dart';

/// Export, import, and delete workout actions.
class ProfileDataManagementSection extends StatelessWidget {
  const ProfileDataManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Data Management',
      subtitle: 'Control your local workout data',
      child: Column(
        children: [
          ProfileActionButton(
            label: 'Export Workouts',
            icon: Icons.upload_rounded,
            onPressed: () =>
                context.read<ProfileBloc>().add(const ExportWorkouts()),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileActionButton(
            label: 'Import Workouts',
            icon: Icons.download_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import workouts will be available soon.'),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileActionButton(
            label: 'Delete All Workouts',
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: () => _confirmDeleteAll(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColorPalette.darkCard,
          title: const Text('Delete all workouts?'),
          content: const Text(
            'This permanently removes every saved workout from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColorPalette.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      HapticService.deleteConfirmed();
      context.read<ProfileBloc>().add(const DeleteAllWorkouts());
    }
  }
}
