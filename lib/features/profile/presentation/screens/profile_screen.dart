import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/premium_scaffold.dart';
import '../../../../core/widgets/selection_chip.dart';
import '../bloc/profile_bloc.dart';

/// Profile creation screen with premium card-based form layout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 13),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColorPalette.primary,
              surface: AppColorPalette.darkCard,
              onSurface: AppColorPalette.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      context.read<ProfileBloc>().add(ProfileDateOfBirthChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => curr.status == ProfileStatus.success,
      listener: (context, state) {
        context.read<ProfileBloc>().add(const ProfileNavigationHandled());
        context.go(RouteConstants.avatar);
      },
      builder: (context, state) {
        return PremiumScaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Create Profile',
                  subtitle: 'Tell us about yourself to personalize your experience.',
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Name
                _FormSection(
                  label: 'Full Name',
                  error: state.nameError,
                  child: _PremiumTextField(
                    controller: _nameController,
                    hint: 'Enter your name',
                    icon: Icons.person_outline,
                    onChanged: (value) => context
                        .read<ProfileBloc>()
                        .add(ProfileNameChanged(value)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Date of Birth
                _FormSection(
                  label: 'Date of Birth',
                  error: state.dateOfBirthError,
                  child: PremiumCard(
                    onTap: _pickDateOfBirth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColorPalette.grey400,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          state.dateOfBirth != null
                              ? DateFormatter.formatDate(state.dateOfBirth!)
                              : 'Select your date of birth',
                          style: TextStyle(
                            color: state.dateOfBirth != null
                                ? AppColorPalette.white
                                : AppColorPalette.grey500,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColorPalette.grey500,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Gender
                _FormSection(
                  label: 'Gender',
                  error: state.genderError,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _genders.map((gender) {
                      return SelectionChip(
                        label: gender,
                        isSelected: state.gender == gender,
                        onTap: () => context
                            .read<ProfileBloc>()
                            .add(ProfileGenderChanged(gender)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Height & Weight row
                Row(
                  children: [
                    Expanded(
                      child: _FormSection(
                        label: 'Height (cm)',
                        error: state.heightError,
                        child: _PremiumTextField(
                          controller: _heightController,
                          hint: '170',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              context.read<ProfileBloc>().add(
                                    ProfileHeightChanged(parsed),
                                  );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _FormSection(
                        label: 'Weight (kg)',
                        error: state.weightError,
                        child: _PremiumTextField(
                          controller: _weightController,
                          hint: '70',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              context.read<ProfileBloc>().add(
                                    ProfileWeightChanged(parsed),
                                  );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),

                GradientButton(
                  label: 'Continue',
                  isLoading: state.status == ProfileStatus.submitting,
                  icon: Icons.arrow_forward,
                  onPressed: () => context
                      .read<ProfileBloc>()
                      .add(const ProfileSubmitted()),
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

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.label,
    required this.child,
    this.error,
  });

  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColorPalette.grey300,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error!,
            style: const TextStyle(
              color: AppColorPalette.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: AppColorPalette.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColorPalette.grey500),
          prefixIcon: Icon(icon, color: AppColorPalette.grey400, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
        ),
      ),
    );
  }
}
