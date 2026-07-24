import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/activity_bloc.dart';
import 'map_dark_style.dart';

/// Full-screen Google Map with live route rendering and user follow mode.
class ActivityMap extends StatefulWidget {
  const ActivityMap({super.key});

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap> {
  GoogleMapController? _controller;
  LatLng? _lastFollowedPosition;

  static const _initialPosition = LatLng(28.6139, 77.2090);

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
        return Stack(
          fit: StackFit.expand,
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 15,
              ),
              style: MapDarkStyle.json,
              myLocationEnabled: state.permissionStatus ==
                  ActivityPermissionStatus.granted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
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
            ),
            if (state.status == ActivityTrackingStatus.locating)
              const _MapLoadingOverlay(message: 'Finding your location...'),
          ],
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

class _MapLoadingOverlay extends StatelessWidget {
  const _MapLoadingOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColorPalette.darkBackground.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColorPalette.primary,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColorPalette.grey300,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
