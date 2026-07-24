import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/premium_scaffold.dart';
import '../../../../core/widgets/selection_chip.dart';
import '../../data/models/avatar_options.dart';
import '../bloc/avatar_bloc.dart';
import '../widgets/avatar_preview.dart';

/// Avatar customization screen with placeholder preview for future 3D.
class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AvatarBloc>().add(const AvatarLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AvatarBloc, AvatarState>(
      listenWhen: (prev, curr) => curr.status == AvatarStatus.success,
      listener: (context, state) {
        context.read<AvatarBloc>().add(const AvatarNavigationHandled());
        context.go(RouteConstants.permissions);
      },
      builder: (context, state) {
        if (state.status == AvatarStatus.loading ||
            state.status == AvatarStatus.initial) {
          return const PremiumScaffold(
            body: LoadingIndicator(message: 'Loading your profile...'),
          );
        }

        return PremiumScaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Choose Avatar',
                  subtitle:
                      'Customize your look. Full 3D avatars coming soon.',
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Preview
                Center(
                  child: AvatarPreview(
                    gender: state.gender ?? AvatarOptions.genders.first,
                    hairStyle:
                        state.hairStyle ?? AvatarOptions.hairStyles.first,
                    skinTone: state.skinTone ?? AvatarOptions.skinTones.first,
                    outfitColor: state.outfitColor ??
                        AvatarOptions.outfitColors.first,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Gender
                const Text(
                  'Body Type',
                  style: TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: AvatarOptions.genders.map((gender) {
                    return SelectionChip(
                      label: gender,
                      isSelected: state.gender == gender,
                      onTap: () => context.read<AvatarBloc>().add(
                            AvatarGenderSelected(gender),
                          ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                AvatarOptionSelector(
                  title: 'Hair Style',
                  options: AvatarOptions.hairStyles,
                  selected:
                      state.hairStyle ?? AvatarOptions.hairStyles.first,
                  onSelected: (value) => context.read<AvatarBloc>().add(
                        AvatarHairStyleSelected(value),
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),

                SkinToneSelector(
                  options: AvatarOptions.skinTones,
                  selected: state.skinTone ?? AvatarOptions.skinTones.first,
                  onSelected: (value) => context.read<AvatarBloc>().add(
                        AvatarSkinToneSelected(value),
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),

                OutfitColorSelector(
                  options: AvatarOptions.outfitColors,
                  selected:
                      state.outfitColor ?? AvatarOptions.outfitColors.first,
                  onSelected: (value) => context.read<AvatarBloc>().add(
                        AvatarOutfitColorSelected(value),
                      ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                GradientButton(
                  label: 'Continue',
                  isLoading: state.status == AvatarStatus.submitting,
                  icon: Icons.arrow_forward,
                  onPressed: () => context
                      .read<AvatarBloc>()
                      .add(const AvatarSubmitted()),
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
