import 'package:flutter/material.dart';

import '../../../../core/navigation/avatar_layout.dart';
import '../../../../core/services/avatar_lifecycle.dart';
import '../../../../core/widgets/avatar_3d_viewer.dart';

/// Single app-wide 3D avatar host. One WebView for the whole session.
///
/// Mounted at the navigation shell so tab switches (Home / History / Analytics)
/// never tear down and recreate the platform view. Only removed on the Activity
/// tab where Google Maps needs the platform-view slot.
class PersistentAvatarHost extends StatefulWidget {
  const PersistentAvatarHost({
    required this.gender,
    required this.suspended,
    required this.visible,
    this.compact = false,
    this.scale = 1.0,
    super.key,
  });

  final String gender;
  final bool suspended;
  final bool visible;
  final bool compact;
  final double scale;

  @override
  State<PersistentAvatarHost> createState() => PersistentAvatarHostState();
}

class PersistentAvatarHostState extends State<PersistentAvatarHost> {
  static const _owner = 'shell';

  bool _mounted = false;
  bool _modelLoaded = false;
  String? _activeGender;

  bool get isModelLoaded => _modelLoaded;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant PersistentAvatarHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.suspended != oldWidget.suspended ||
        widget.gender != oldWidget.gender) {
      _sync();
    }
  }

  @override
  void dispose() {
    if (_mounted) {
      AvatarLifecycle.release(_owner);
    }
    super.dispose();
  }

  void _sync() {
    if (widget.suspended) {
      if (_mounted) {
        AvatarLifecycle.release(_owner);
        setState(() {
          _mounted = false;
          _modelLoaded = false;
        });
      }
      return;
    }

    final assetPath = Avatar3DViewer.assetForGender(widget.gender);
    final alreadyCached = AvatarPreloadCache.hasLoaded(assetPath);

    if (!_mounted) {
      AvatarLifecycle.acquire(_owner);
      setState(() {
        _mounted = true;
        _activeGender = widget.gender;
        _modelLoaded = alreadyCached;
      });
      return;
    }

    if (_activeGender != widget.gender) {
      setState(() {
        _activeGender = widget.gender;
        _modelLoaded = alreadyCached;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_mounted || widget.suspended) {
      return const SizedBox.shrink();
    }

    final assetPath = Avatar3DViewer.assetForGender(widget.gender);
    final showSpinner = widget.visible && !_modelLoaded;

    final viewer = Avatar3DViewer(
      key: ValueKey(assetPath),
      assetPath: assetPath,
      backgroundColor: Colors.transparent,
      cameraOrbit: widget.compact ? '0deg 76deg 82%' : '0deg 75deg 110%',
      cameraTarget: widget.compact ? 'auto 0.82m auto' : 'auto 0.9m auto',
      fieldOfView: widget.compact ? '26deg' : '30deg',
      onLoaded: () {
        if (!mounted) return;
        setState(() => _modelLoaded = true);
      },
    );

    final scaled = widget.scale != 1.0
        ? Transform.scale(
            scale: widget.scale,
            alignment: Alignment.bottomCenter,
            child: viewer,
          )
        : viewer;

    return IgnorePointer(
      ignoring: !widget.visible,
      child: Opacity(
        opacity: widget.visible ? 1 : 0,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: scaled),
            if (showSpinner)
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Layout slot on the home hero — reserves space; rendering is done by
/// [PersistentAvatarHost] in the navigation shell.
class AvatarCard extends StatefulWidget {
  const AvatarCard({
    this.fillHeight = false,
    this.compact = false,
    super.key,
  });

  final bool fillHeight;
  final bool compact;

  @override
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyAvatarLayoutChanged());
  }

  @override
  void didUpdateWidget(covariant AvatarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyAvatarLayoutChanged());
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyAvatarLayoutChanged());

    final screenHeight = MediaQuery.sizeOf(context).height;
    final avatarHeight = widget.fillHeight
        ? null
        : widget.compact
            ? 240.0
            : (screenHeight * 0.42).clamp(280.0, 420.0);

    if (avatarHeight == null) {
      return const SizedBox.expand();
    }

    return SizedBox(
      height: avatarHeight,
      width: double.infinity,
    );
  }
}
