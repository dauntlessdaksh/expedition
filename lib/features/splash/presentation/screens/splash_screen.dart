import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../bloc/splash_bloc.dart';

/// Animated splash screen that checks for existing user data.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        context.read<SplashBloc>().add(const SplashAnimationCompleted());
      }
    });

    context.read<SplashBloc>().add(const SplashStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateIfReady(SplashState state) {
    if (!state.canNavigate) return;

    switch (state.destination) {
      case SplashDestination.home:
        context.go(RouteConstants.home);
      case SplashDestination.onboarding:
        context.go(RouteConstants.onboarding);
      case SplashDestination.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) => _navigateIfReady(state),
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: PremiumGradients.darkBackground,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorPalette.primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: PremiumGradients.accentButton,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColorPalette.primary
                                  .withValues(alpha: 0.4),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.terrain,
                          size: 48,
                          color: AppColorPalette.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: AppColorPalette.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your journey starts here',
                        style: TextStyle(
                          color: AppColorPalette.grey400,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
