import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../services/avatar_lifecycle.dart';

/// Ensures embedded GLB animations loop continuously after the model loads.
const kAvatarAnimationLoopScript = '''
(() => {
  const bindLoop = () => {
    const modelViewer = document.querySelector('model-viewer');
    if (!modelViewer) {
      return;
    }

    const startLoop = () => {
      const animations = modelViewer.availableAnimations || [];
      if (animations.length === 0) {
        return;
      }

      modelViewer.animationName = animations[0];
      modelViewer.play({ repetitions: Infinity });
    };

    if (modelViewer.loaded) {
      startLoop();
      return;
    }

    modelViewer.addEventListener('load', startLoop, { once: true });
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bindLoop, { once: true });
  } else {
    bindLoop();
  }
})();
''';

/// Reusable 3D avatar viewer for GLB models with running animation.
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
    this.onLoaded,
  });

  final String assetPath;
  final Color backgroundColor;
  final String cameraOrbit;
  final String cameraTarget;
  final String fieldOfView;
  final bool interactionEnabled;
  final bool enabled;
  final VoidCallback? onLoaded;

  static String assetForGender(String gender) {
    return gender.toLowerCase() == 'female'
        ? AppAssets.femaleRunningGlb
        : AppAssets.maleRunningGlb;
  }

  @override
  State<Avatar3DViewer> createState() => _Avatar3DViewerState();
}

class _Avatar3DViewerState extends State<Avatar3DViewer> {
  bool _showViewer = false;
  String? _activeAssetPath;
  int _viewerGeneration = 0;
  bool _loadedNotified = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _mountViewer(widget.assetPath);
    }
  }

  @override
  void didUpdateWidget(covariant Avatar3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.enabled) {
      if (_activeAssetPath != null) {
        setState(() {
          _showViewer = false;
          _activeAssetPath = null;
          _loadedNotified = false;
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
      _loadedNotified = false;
    });

    if (AvatarPreloadCache.hasLoaded(assetPath)) {
      if (!mounted || !widget.enabled || widget.assetPath != assetPath) {
        return;
      }
      _mountViewer(assetPath);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 150));
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
      _loadedNotified = false;
    });
  }

  void _notifyLoadedOnce() {
    if (_loadedNotified || !mounted) {
      return;
    }

    _loadedNotified = true;
    AvatarPreloadCache.markLoaded(widget.assetPath);
    widget.onLoaded?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !_showViewer || _activeAssetPath == null) {
      return _AvatarViewerPlaceholder(backgroundColor: widget.backgroundColor);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ModelViewer(
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
            loading: Loading.eager,
            relatedJs: kAvatarAnimationLoopScript,
            onWebViewCreated: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _notifyLoadedOnce();
              });
            },
          ),
        );
      },
    );
  }
}

class _AvatarViewerPlaceholder extends StatelessWidget {
  const _AvatarViewerPlaceholder({required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isTransparent = backgroundColor.a == 0;

    return ColoredBox(
      color: isTransparent ? Colors.transparent : backgroundColor,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColorPalette.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
