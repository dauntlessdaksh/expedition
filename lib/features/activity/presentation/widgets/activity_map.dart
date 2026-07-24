import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/widgets/skeleton/skeleton_loaders.dart';
import '../bloc/activity_bloc.dart';
import 'activity_tab_scope.dart';
import 'map_styles.dart';

/// Full-screen Google Map with live route rendering and user follow mode.
class ActivityMap extends StatefulWidget {
  const ActivityMap({super.key});

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap> {
  GoogleMapController? _controller;
  LatLng? _lastFollowedPosition;
  Brightness? _mapBrightness;

  static const _initialPosition = LatLng(28.6139, 77.2090);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_mapBrightness != brightness) {
      _mapBrightness = brightness;
      _controller?.setMapStyle(MapStyles.forContext(context));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listenWhen: (previous, current) =>
          previous.currentPosition != current.currentPosition ||
          previous.followUser != current.followUser,
      listener: (context, state) {
        _maybeFollowUser(state);
      },
      buildWhen: (previous, current) =>
          previous.routePoints != current.routePoints ||
          previous.permissionStatus != current.permissionStatus,
      builder: (context, state) {
        final isTabActive = ActivityTabActiveScope.of(context);
        final showMap = isTabActive || state.isSessionActive;
        final mapStyle = MapStyles.forContext(context);
        final placeholderColor = Theme.of(context).colorScheme.surface;

        return RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (showMap)
                GoogleMap(
                  key: ValueKey(mapStyle),
                  initialCameraPosition: const CameraPosition(
                    target: _initialPosition,
                    zoom: 15,
                  ),
                  style: mapStyle,
                  myLocationEnabled: state.permissionStatus ==
                      ActivityPermissionStatus.granted,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  polylines: state.polylines,
                  onMapCreated: (controller) {
                    _controller = controller;
                    final currentState = context.read<ActivityBloc>().state;
                    if (currentState.currentPosition != null) {
                      _maybeFollowUser(currentState, force: true);
                    }
                  },
                  onCameraMoveStarted: () {
                    final followUser =
                        context.read<ActivityBloc>().state.followUser;
                    if (followUser) {
                      context.read<ActivityBloc>().add(
                            const FollowUserToggled(followUser: false),
                          );
                    }
                  },
                )
              else
                ColoredBox(color: placeholderColor),
              if (state.status == ActivityTrackingStatus.locating && showMap)
                SkeletonLoaders.activityMapOverlay(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _maybeFollowUser(
    ActivityState state, {
    bool force = false,
  }) async {
    if (!state.followUser || state.currentPosition == null) {
      return;
    }

    if (!force &&
        _lastFollowedPosition != null &&
        _lastFollowedPosition == state.currentPosition) {
      return;
    }

    _lastFollowedPosition = state.currentPosition;
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(state.currentPosition!, 16.5),
    );
  }
}
