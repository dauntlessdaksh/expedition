import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/avatar_lifecycle.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../home/presentation/widgets/home_animated_section.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_about_section.dart';
import '../widgets/profile_achievements_section.dart';
import '../widgets/profile_data_management_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_personal_info_section.dart';
import '../widgets/profile_preferences_section.dart';
import '../widgets/profile_workout_preferences_section.dart';

/// Premium profile and settings screen accessed from the home header.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _avatarOwner = 'profile';

  @override
  void initState() {
    super.initState();
    AvatarLifecycle.acquire(_avatarOwner);
  }

  @override
  void dispose() {
    AvatarLifecycle.release(_avatarOwner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.message != current.message ||
          previous.exportResult?.filePath != current.exportResult?.filePath,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          context.read<ProfileBloc>().add(const ClearProfileMessage());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColorPalette.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: const Text('Profile'),
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: PremiumGradients.darkBackground,
            ),
            child: switch (state.status) {
              ProfileStatus.initial ||
              ProfileStatus.loading =>
                const LoadingIndicator(message: 'Loading profile...'),
              ProfileStatus.failure => _ProfileError(
                  onRetry: () =>
                      context.read<ProfileBloc>().add(const LoadProfile()),
                ),
              ProfileStatus.loaded when state.data != null =>
                _ProfileContent(
                  state: state,
                  onThemeChanged: (theme) {
                    final mode = theme == 'dark'
                        ? ThemeMode.dark
                        : ThemeMode.system;
                    context.read<ThemeCubit>().setThemeMode(mode);
                  },
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.state,
    required this.onThemeChanged,
  });

  final ProfileState state;
  final ValueChanged<String> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final data = state.data!;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.sm,
                AppSpacing.xxl,
                AppSpacing.xxxl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  HomeAnimatedSection(
                    index: 0,
                    child: ProfileHeader(data: data),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HomeAnimatedSection(
                    index: 1,
                    child: ProfilePersonalInfoSection(data: data),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HomeAnimatedSection(
                    index: 2,
                    child: ProfilePreferencesSection(
                      preferences: data.preferences,
                      onThemeChanged: onThemeChanged,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HomeAnimatedSection(
                    index: 3,
                    child: ProfileWorkoutPreferencesSection(
                      preferences: data.preferences,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HomeAnimatedSection(
                    index: 4,
                    child: ProfileAchievementsSection(
                      achievements: data.achievements,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HomeAnimatedSection(
                    index: 5,
                    child: const ProfileDataManagementSection(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  HomeAnimatedSection(
                    index: 6,
                    child: const ProfileAboutSection(),
                  ),
                ]),
              ),
            ),
          ],
        ),
        if (state.isSaving)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: AppColorPalette.primary,
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColorPalette.error,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Unable to load profile.',
            style: TextStyle(
              color: AppColorPalette.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
