import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/premium_scaffold.dart';
import '../../../../core/widgets/selection_chip.dart';
import '../bloc/permission_bloc.dart';
import '../widgets/permission_card.dart';

/// Permissions screen explaining why each permission is needed.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PermissionBloc, PermissionState>(
      listenWhen: (prev, curr) =>
          curr.status == PermissionFlowStatus.completed,
      listener: (context, state) {
        context.read<PermissionBloc>().add(
              const PermissionNavigationHandled(),
            );
        context.go(RouteConstants.home);
      },
      builder: (context, state) {
        return PremiumScaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Permissions',
                  subtitle:
                      'Expedition needs a few permissions to track your activities and keep you motivated.',
                ),
                const SizedBox(height: AppSpacing.xxxl),
                PermissionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  description:
                      'Record GPS routes during walks, runs, and rides.',
                  status: state.locationStatus,
                  isGranted: state.locationGranted,
                  onAllow: () => context.read<PermissionBloc>().add(
                        const PermissionLocationRequested(),
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PermissionCard(
                  icon: Icons.directions_run,
                  title: 'Activity Recognition',
                  description:
                      'Automatically detect when you start and stop moving.',
                  status: state.activityStatus,
                  isGranted: state.activityGranted,
                  onAllow: () => context.read<PermissionBloc>().add(
                        const PermissionActivityRequested(),
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PermissionCard(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  description:
                      'Receive reminders and celebrate your achievements.',
                  status: state.notificationStatus,
                  isGranted: state.notificationGranted,
                  onAllow: () => context.read<PermissionBloc>().add(
                        const PermissionNotificationRequested(),
                      ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                GradientButton(
                  label: 'Continue to Expedition',
                  isLoading:
                      state.status == PermissionFlowStatus.completing,
                  icon: Icons.arrow_forward,
                  onPressed: () => context.read<PermissionBloc>().add(
                        const PermissionContinuePressed(),
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}
