import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../../../core/widgets/premium_scaffold.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_page.dart';

/// Three-page onboarding experience with PageView navigation.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    context.read<OnboardingBloc>().add(OnboardingPageChanged(page));
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (prev, curr) =>
          curr.navigationTarget != OnboardingNavigation.none,
      listener: (context, state) {
        if (state.navigationTarget == OnboardingNavigation.profile) {
          context.read<OnboardingBloc>().add(
                const OnboardingNavigationHandled(),
              );
          context.go(RouteConstants.profile);
        }
      },
      builder: (context, state) {
        return PremiumScaffold(
          body: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: GhostButton(
                    label: 'Skip',
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingSkipPressed()),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: OnboardingBloc.totalPages,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      data: OnboardingContent.pages[index],
                    );
                  },
                ),
              ),
              PageIndicator(
                count: OnboardingBloc.totalPages,
                currentIndex: state.currentPage,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: GradientButton(
                  label: state.isLastPage ? 'Get Started' : 'Next',
                  icon: state.isLastPage ? Icons.arrow_forward : null,
                  onPressed: () {
                    if (state.isLastPage) {
                      context.read<OnboardingBloc>().add(
                            const OnboardingGetStartedPressed(),
                          );
                    } else {
                      final nextPage = state.currentPage + 1;
                      context.read<OnboardingBloc>().add(
                            const OnboardingNextPressed(),
                          );
                      _animateToPage(nextPage);
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        );
      },
    );
  }
}
