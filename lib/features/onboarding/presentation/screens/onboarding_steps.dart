import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../data/models/activity_level.dart';
import '../../data/models/fitness_goal.dart';
import '../../data/models/gender.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_inputs.dart';
import '../widgets/onboarding_option_card.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/onboarding_wheel_picker.dart';

/// Welcome step — hero introduction before data collection.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: PremiumGradients.darkBackground,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const Spacer(),
              const OnboardingHeroOrb(),
              const SizedBox(height: AppSpacing.xxxl),
              const Text(
                'Welcome to\n${AppStrings.appName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Your personal fitness companion.\nTrack every journey, offline-first.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColorPalette.grey400,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              GradientButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () =>
                    context.read<OnboardingBloc>().add(const OnboardingNextPressed()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Name collection step.
class NameStep extends StatefulWidget {
  const NameStep({required this.state, super.key});

  final OnboardingState state;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.data.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();

    return OnboardingScaffold(
      title: "What's your name?",
      subtitle: "We'll use this to personalize your experience.",
      progress: widget.state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      validationError: widget.state.validationError,
      body: OnboardingTextField(
        controller: _controller,
        hint: 'First name',
        onChanged: (value) => bloc.add(OnboardingNameChanged(value)),
      ),
    );
  }
}

/// Gender selection step.
class GenderStep extends StatelessWidget {
  const GenderStep({required this.state, super.key});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();

    return OnboardingScaffold(
      title: 'Select your gender',
      subtitle: 'This helps us tailor your fitness experience.',
      progress: state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      validationError: state.validationError,
      body: Column(
        children: Gender.values.map((gender) {
          final isSelected = state.data.gender == gender;
          return OnboardingOptionCard(
            title: gender.label,
            isSelected: isSelected,
            onTap: () => bloc.add(OnboardingGenderSelected(gender)),
            leading: GenderLeadingIcon(
              icon: gender == Gender.male
                  ? Icons.male_rounded
                  : Icons.female_rounded,
              isSelected: isSelected,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Age picker step.
class AgeStep extends StatelessWidget {
  const AgeStep({required this.state, super.key});

  final OnboardingState state;

  static const _minAge = 13;
  static const _maxAge = 100;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final ages = List.generate(
      _maxAge - _minAge + 1,
      (i) => '${_minAge + i}',
    );
    final selectedIndex = (state.data.age - _minAge).clamp(0, ages.length - 1);

    return OnboardingScaffold(
      title: 'How old are you?',
      subtitle: 'Age helps us calculate accurate metrics.',
      progress: state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      body: OnboardingWheelPicker(
        values: ages,
        selectedIndex: selectedIndex,
        unit: 'years',
        onChanged: (index) =>
            bloc.add(OnboardingAgeChanged(_minAge + index)),
      ),
    );
  }
}

/// Height picker step.
class HeightStep extends StatelessWidget {
  const HeightStep({required this.state, super.key});

  final OnboardingState state;

  static const _minHeight = 100;
  static const _maxHeight = 250;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final heights = List.generate(
      _maxHeight - _minHeight + 1,
      (i) => '${_minHeight + i}',
    );
    final selectedIndex =
        (state.data.height.round() - _minHeight).clamp(0, heights.length - 1);

    return OnboardingScaffold(
      title: 'Your height',
      subtitle: 'Used for calorie and distance calculations.',
      progress: state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      body: OnboardingWheelPicker(
        values: heights,
        selectedIndex: selectedIndex,
        unit: 'cm',
        onChanged: (index) =>
            bloc.add(OnboardingHeightChanged((_minHeight + index).toDouble())),
      ),
    );
  }
}

/// Weight picker step.
class WeightStep extends StatelessWidget {
  const WeightStep({required this.state, super.key});

  final OnboardingState state;

  static const _minWeight = 30;
  static const _maxWeight = 200;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final weights = List.generate(
      _maxWeight - _minWeight + 1,
      (i) => '${_minWeight + i}',
    );
    final selectedIndex =
        (state.data.weight.round() - _minWeight).clamp(0, weights.length - 1);

    return OnboardingScaffold(
      title: 'Your weight',
      subtitle: 'Helps track progress toward your goals.',
      progress: state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      body: OnboardingWheelPicker(
        values: weights,
        selectedIndex: selectedIndex,
        unit: 'kg',
        onChanged: (index) =>
            bloc.add(OnboardingWeightChanged((_minWeight + index).toDouble())),
      ),
    );
  }
}

/// Fitness goal selection step.
class FitnessGoalStep extends StatelessWidget {
  const FitnessGoalStep({required this.state, super.key});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();

    return OnboardingScaffold(
      title: 'Your fitness goal',
      subtitle: 'What would you like to achieve?',
      progress: state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      validationError: state.validationError,
      body: Column(
        children: FitnessGoal.values.map((goal) {
          return OnboardingOptionCard(
            title: goal.label,
            subtitle: goal.description,
            icon: goal.icon,
            isSelected: state.data.fitnessGoal == goal,
            onTap: () => bloc.add(OnboardingFitnessGoalSelected(goal)),
          );
        }).toList(),
      ),
    );
  }
}

/// Activity level selection step.
class ActivityLevelStep extends StatelessWidget {
  const ActivityLevelStep({required this.state, super.key});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();

    return OnboardingScaffold(
      title: 'Activity level',
      subtitle: 'How would you describe your current fitness?',
      progress: state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      validationError: state.validationError,
      body: Column(
        children: ActivityLevel.values.map((level) {
          return OnboardingOptionCard(
            title: level.label,
            subtitle: level.description,
            icon: level.icon,
            isSelected: state.data.activityLevel == level,
            onTap: () => bloc.add(OnboardingActivityLevelSelected(level)),
          );
        }).toList(),
      ),
    );
  }
}

/// Permissions explanation step — no requests made here.
class PermissionsStep extends StatelessWidget {
  const PermissionsStep({required this.state, super.key});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();

    return OnboardingScaffold(
      title: 'App permissions',
      subtitle: "We'll ask for these later when you're ready to track.",
      progress: state.progress,
      onBack: () => bloc.add(const OnboardingBackPressed()),
      onContinue: () => bloc.add(const OnboardingNextPressed()),
      continueLabel: 'Get Started',
      isLoading: state.status == OnboardingStatus.submitting,
      validationError: state.validationError,
      body: const Column(
        children: [
          OnboardingInfoCard(
            icon: Icons.location_on_outlined,
            title: 'Location',
            description:
                'Record GPS routes during walks, runs, and rides.',
          ),
          OnboardingInfoCard(
            icon: Icons.directions_run_outlined,
            title: 'Activity Recognition',
            description:
                'Automatically detect when you start and stop moving.',
          ),
          OnboardingInfoCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            description:
                'Receive reminders and celebrate your achievements.',
          ),
        ],
      ),
    );
  }
}
