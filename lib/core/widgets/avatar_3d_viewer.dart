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
///
/// Safely remounts the underlying WebView when [assetPath] changes to avoid
/// Android crashes from hot-swapping GLB assets in a live platform view.
class Avatar3DViewer extends StatefulWidget {
  const Avatar3DViewer({
    required this.assetPath,
    super.key,
    this.backgroundColor = AppColorPalette.darkCard,
    this.cameraOrbit = '0deg 75deg 110%',
    this.cameraTarget = 'auto 0.9m auto',
    this.fieldOfView = '30deg',
    this.interactionEnabled = false,
    this.enabled = true,
  });

  final String assetPath;
  final Color backgroundColor;
  final String cameraOrbit;
  final String cameraTarget;
  final String fieldOfView;
  final bool interactionEnabled;
  final bool enabled;

  static String assetForGender(String gender) {
    return gender.toLowerCase() == 'female'
        ? AppAssets.femaleRunningGlb
        : AppAssets.maleRunningGlb;
  }

  @override
  State<Avatar3DViewer> createState() => _Avatar3DViewerState();
}

class _Avatar3DViewerState extends State<Avatar3DViewer> {
  bool _showViewer = true;
  String? _activeAssetPath;
  int _viewerGeneration = 0;

  @override
  void initState() {
    super.initState();
    _activeAssetPath = widget.enabled ? widget.assetPath : null;
  }

  @override
  void didUpdateWidget(covariant Avatar3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled) {
      if (_activeAssetPath != null) {
        setState(() {
          _showViewer = false;
          _activeAssetPath = null;
        });
      }
      return;
    }

    if (!oldWidget.enabled && widget.enabled) {
      _mountViewer(widget.assetPath);
      return;
    }

    if (oldWidget.assetPath != widget.assetPath) {
      _remountViewer(widget.assetPath);
    }
  }

  Future<void> _remountViewer(String assetPath) async {
    setState(() {
      _showViewer = false;
      _activeAssetPath = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted || !widget.enabled || widget.assetPath != assetPath) {
      return;
    }

    _mountViewer(assetPath);
  }

  void _mountViewer(String assetPath) {
    setState(() {
      _activeAssetPath = assetPath;
      _showViewer = true;
      _viewerGeneration++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !_showViewer || _activeAssetPath == null) {
      return _AvatarViewerPlaceholder(backgroundColor: widget.backgroundColor);
    }

    return ModelViewer(
      key: ValueKey('avatar-${_viewerGeneration}_$_activeAssetPath'),
      src: _activeAssetPath!,
      alt: 'Expedition avatar',
      ar: false,
      autoPlay: true,
      autoRotate: false,
      cameraControls: widget.interactionEnabled,
      disableZoom: !widget.interactionEnabled,
      disablePan: !widget.interactionEnabled,
      backgroundColor: widget.backgroundColor,
      cameraOrbit: widget.cameraOrbit,
      cameraTarget: widget.cameraTarget,
      fieldOfView: widget.fieldOfView,
      interactionPrompt: InteractionPrompt.none,
      loading: Loading.lazy,
      relatedJs: kAvatarAnimationLoopScript,
    );
  }
}

class _AvatarViewerPlaceholder extends StatelessWidget {
  const _AvatarViewerPlaceholder({required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: const Center(
        child: Icon(
          Icons.directions_run_rounded,
          color: AppColorPalette.primary,
          size: 56,
        ),
      ),
    );
  }
}
