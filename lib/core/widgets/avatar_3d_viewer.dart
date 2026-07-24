import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

/// Ensures embedded GLB animations loop continuously after the model loads.
const kAvatarAnimationLoopScript = '''
document.addEventListener('DOMContentLoaded', () => {
  const modelViewer = document.querySelector('model-viewer');
  if (!modelViewer) return;

  modelViewer.addEventListener('load', () => {
    const animations = modelViewer.availableAnimations;
    if (!animations || animations.length === 0) return;

    modelViewer.animationName = animations[0];
    modelViewer.play({ repetitions: Infinity });
  });
});
''';

/// Reusable 3D avatar viewer for GLB models with running animation.
class Avatar3DViewer extends StatelessWidget {
  const Avatar3DViewer({
    required this.assetPath,
    super.key,
    this.backgroundColor = AppColorPalette.darkCard,
    this.cameraOrbit = '0deg 75deg 110%',
    this.cameraTarget = 'auto 0.9m auto',
    this.fieldOfView = '30deg',
    this.interactionEnabled = false,
  });

  final String assetPath;
  final Color backgroundColor;
  final String cameraOrbit;
  final String cameraTarget;
  final String fieldOfView;
  final bool interactionEnabled;

  static String assetForGender(String gender) {
    return gender.toLowerCase() == 'female'
        ? AppAssets.femaleRunningGlb
        : AppAssets.maleRunningGlb;
  }

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      src: assetPath,
      alt: 'Expedition avatar',
      ar: false,
      autoPlay: true,
      autoRotate: false,
      cameraControls: interactionEnabled,
      disableZoom: !interactionEnabled,
      disablePan: !interactionEnabled,
      backgroundColor: backgroundColor,
      cameraOrbit: cameraOrbit,
      cameraTarget: cameraTarget,
      fieldOfView: fieldOfView,
      interactionPrompt: InteractionPrompt.none,
      loading: Loading.eager,
      relatedJs: kAvatarAnimationLoopScript,
    );
  }
}
