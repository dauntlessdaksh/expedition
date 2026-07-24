import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/avatar_3d_viewer.dart';

/// Proof-of-concept screen for verifying GLB model loading and animation.
class AvatarTestScreen extends StatelessWidget {
  const AvatarTestScreen({super.key});

  static const Color _backgroundColor = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Avatar Test'),
        backgroundColor: _backgroundColor,
        foregroundColor: AppColorPalette.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Avatar3DViewer(
              assetPath: AppAssets.maleRunningGlb,
              backgroundColor: _backgroundColor,
              interactionEnabled: true,
            ),
          );
        },
      ),
    );
  }
}
