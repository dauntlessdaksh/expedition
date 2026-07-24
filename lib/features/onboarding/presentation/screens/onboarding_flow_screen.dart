import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../bloc/onboarding_bloc.dart';
import 'onboarding_steps.dart';

/// Hosts the multi-step onboarding flow driven by [OnboardingBloc].
class OnboardingFlowScreen extends StatelessWidget {
  const OnboardingFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (prev, curr) => curr.status == OnboardingStatus.completed,
      listener: (context, state) {
        context.read<OnboardingBloc>().add(const OnboardingNavigationHandled());
        context.go(RouteConstants.home);
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(state.currentStep),
            child: _buildStep(state),
          ),
        );
      },
    );
  }

  Widget _buildStep(OnboardingState state) {
    return switch (state.currentStep) {
      OnboardingStep.welcome => const WelcomeStep(),
      OnboardingStep.name => NameStep(state: state),
      OnboardingStep.gender => GenderStep(state: state),
      OnboardingStep.age => AgeStep(state: state),
      OnboardingStep.height => HeightStep(state: state),
      OnboardingStep.weight => WeightStep(state: state),
      OnboardingStep.fitnessGoal => FitnessGoalStep(state: state),
      OnboardingStep.activityLevel => ActivityLevelStep(state: state),
      OnboardingStep.permissions => PermissionsStep(state: state),
    };
  }
}
