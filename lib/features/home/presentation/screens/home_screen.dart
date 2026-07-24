import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Placeholder home screen for Phase 3 development.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: PremiumGradients.darkBackground,
        ),
        child: const SafeArea(
          child: Center(
            child: Text(
              'Home',
              style: TextStyle(
                color: AppColorPalette.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
