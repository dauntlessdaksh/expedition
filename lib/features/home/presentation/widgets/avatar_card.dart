import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/avatar_lifecycle.dart';
import '../../../../core/widgets/avatar_3d_viewer.dart';

/// Hero 3D avatar for the home screen.
///
/// Keeps the WebView alive when [visible] is false (e.g. History tab) so tab
/// switches back to Home are instant. Only tears down when [suspended] is
/// true (Activity map or Profile avatar need the platform view).
class AvatarCard extends StatefulWidget {
  const AvatarCard({
    required this.gender,
    this.visible = true,
    this.suspended = false,
    this.compact = false,
    this.fillHeight = false,
    this.scale = 1.0,
    super.key,
  });

  final String gender;
  final bool visible;
  final bool suspended;
  final bool compact;
  final bool fillHeight;
  final double scale;

  @override
  State<AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<AvatarCard>
    with AutomaticKeepAliveClientMixin {
  static const _avatarOwner = 'home';

  bool _viewerMounted = false;
  bool _modelLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _syncViewerState();
  }

  @override
  void didUpdateWidget(covariant AvatarCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.suspended != oldWidget.suspended ||
        widget.visible != oldWidget.visible) {
      _syncViewerState();
    }
  }

  @override
  void dispose() {
    _releaseViewer();
    super.dispose();
  }

  void _syncViewerState() {
    if (widget.suspended) {
      _releaseViewer();
      return;
    }

    if (!_viewerMounted) {
      AvatarLifecycle.acquire(_avatarOwner);
      setState(() {
        _viewerMounted = true;
        _modelLoaded = AvatarPreloadCache.hasLoaded(
          Avatar3DViewer.assetForGender(widget.gender),
        );
      });
    }
  }

  void _releaseViewer() {
    AvatarLifecycle.release(_avatarOwner);
    if (_viewerMounted) {
      setState(() {
        _viewerMounted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenHeight = MediaQuery.sizeOf(context).height;
    final avatarHeight = widget.fillHeight
        ? null
        : widget.compact
            ? 240.0
            : (screenHeight * 0.42).clamp(280.0, 420.0);

    final assetPath = Avatar3DViewer.assetForGender(widget.gender);
    final showPlaceholder = !_viewerMounted || (!_modelLoaded && widget.visible);

    final viewer = _viewerMounted
        ? Avatar3DViewer(
            assetPath: assetPath,
            backgroundColor: Colors.transparent,
            cameraOrbit: widget.compact ? '0deg 76deg 82%' : '0deg 75deg 110%',
            cameraTarget: widget.compact ? 'auto 0.82m auto' : 'auto 0.9m auto',
            fieldOfView: widget.compact ? '26deg' : '30deg',
            onLoaded: () {
              if (!mounted) {
                return;
              }
              setState(() => _modelLoaded = true);
            },
          )
        : const _AvatarPlaceholder(loading: true);

    final scaledViewer = widget.scale != 1.0
        ? Transform.scale(
            scale: widget.scale,
            alignment: Alignment.bottomCenter,
            child: viewer,
          )
        : viewer;

    final content = Offstage(
      offstage: !widget.visible,
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: scaledViewer,
            ),
            if (showPlaceholder && widget.visible)
              const Positioned.fill(
                child: _AvatarPlaceholder(loading: true),
              ),
          ],
        ),
      ),
    );

    if (avatarHeight == null) {
      return content;
    }

    return SizedBox(
      height: avatarHeight,
      width: double.infinity,
      child: content,
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColorPalette.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
