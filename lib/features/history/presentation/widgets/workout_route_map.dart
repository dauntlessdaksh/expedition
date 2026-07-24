import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/gradient_polyline.dart';
import '../../../activity/presentation/widgets/map_styles.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/workout_analytics.dart';

/// Premium interactive map for a saved workout route.
class WorkoutRouteMap extends StatefulWidget {
  const WorkoutRouteMap({
    required this.workout,
    this.usePaceGradient = false,
    super.key,
  });

  final Workout workout;
  final bool usePaceGradient;

  @override
  State<WorkoutRouteMap> createState() => _WorkoutRouteMapState();
}

class _WorkoutRouteMapState extends State<WorkoutRouteMap>
    with TickerProviderStateMixin {
  GoogleMapController? _controller;

  late List<LatLng> _routePoints;
  Set<Polyline> _polylines = const {};
  Set<Marker> _markers = const {};

  late final AnimationController _fadeController;
  late final AnimationController _routeDrawController;
  late final AnimationController _markerFadeController;

  bool _userInteracted = false;
  int? _loadedWorkoutId;
  Brightness? _mapBrightness;

  static const _boundsPadding = 72.0;
  static const _singlePointZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _routeDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _markerFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _loadRouteData();
    _fadeController.forward();
    _routeDrawController.addListener(_onRouteAnimationTick);
    _routeDrawController.forward().then((_) {
      if (mounted) {
        setState(() => _rebuildMapOverlays(showMarkers: true));
        _markerFadeController.forward(from: 0);
      }
    });
    _markerFadeController.addListener(_onMarkerAnimationTick);
  }

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
  void didUpdateWidget(covariant WorkoutRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workout.id != widget.workout.id ||
        oldWidget.workout.polyline.length != widget.workout.polyline.length ||
        oldWidget.usePaceGradient != widget.usePaceGradient) {
      _userInteracted = false;
      _loadRouteData();
      _routeDrawController
        ..reset()
        ..forward().then((_) {
          if (mounted) {
            setState(() => _rebuildMapOverlays(showMarkers: true));
            _markerFadeController.forward(from: 0);
          }
        });
      _scheduleCameraFit();
    }
  }

  @override
  void dispose() {
    _routeDrawController.removeListener(_onRouteAnimationTick);
    _markerFadeController.removeListener(_onMarkerAnimationTick);
    _fadeController.dispose();
    _routeDrawController.dispose();
    _markerFadeController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _loadRouteData() {
    _routePoints = List<LatLng>.from(widget.workout.polyline);
    _loadedWorkoutId = widget.workout.id;
    _logRouteDebug();
    _rebuildMapOverlays(showMarkers: false);
  }

  void _onRouteAnimationTick() {
    if (!mounted) {
      return;
    }
    setState(() => _rebuildMapOverlays(showMarkers: false));
  }

  void _onMarkerAnimationTick() {
    if (!mounted || _markerFadeController.value <= 0) {
      return;
    }
    setState(() => _rebuildMapOverlays(showMarkers: true));
  }

  void _rebuildMapOverlays({required bool showMarkers}) {
    if (_routePoints.isEmpty) {
      _polylines = const {};
      _markers = const {};
      return;
    }

    final visiblePoints = showMarkers && _routeDrawController.value >= 1
        ? _routePoints
        : _visibleRoutePoints(_routeDrawController.value);

    _polylines = _buildPolylines(visiblePoints);
    _markers = showMarkers ? _buildMarkers(_routePoints) : const {};
  }

  List<LatLng> _visibleRoutePoints(double progress) {
    if (_routePoints.length < 2) {
      return _routePoints;
    }

    final minPoints = 2;
    final targetCount = math.max(
      minPoints,
      (minPoints + ((_routePoints.length - minPoints) * progress)).round(),
    );

    return _routePoints.sublist(0, targetCount.clamp(1, _routePoints.length));
  }

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    if (points.length < 2) {
      return const {};
    }

    if (widget.usePaceGradient) {
      final paces = WorkoutAnalytics.segmentPaces(
        points: _routePoints,
        paceSamples: widget.workout.paceSamples,
        durationSeconds: widget.workout.durationInSeconds,
      );
      return GradientPolyline.buildByPace(
        points,
        paces,
        idPrefix: 'workout_${widget.workout.id ?? 0}',
        width: 7,
      );
    }

    return {
      Polyline(
        polylineId: PolylineId('workout_route_${widget.workout.id ?? 0}'),
        points: points,
        color: AppColorPalette.primary,
        width: 7,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      ),
    };
  }

  Set<Marker> _buildMarkers(List<LatLng> points) {
    return {
      Marker(
        markerId: const MarkerId('start'),
        position: points.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      if (points.length > 1)
        Marker(
          markerId: const MarkerId('finish'),
          position: points.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
    };
  }

  LatLngBounds? _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return null;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    const padding = 0.0015;
    if ((maxLat - minLat).abs() < padding) {
      minLat -= padding;
      maxLat += padding;
    }
    if ((maxLng - minLng).abs() < padding) {
      minLng -= padding;
      maxLng += padding;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _fitRoute({int attempt = 0}) async {
    final controller = _controller;
    final points = _routePoints;

    if (controller == null || points.isEmpty || _userInteracted) {
      return;
    }

    if (points.length == 1) {
      final target = points.first;
      _logCameraDebug(
        pointCount: points.length,
        bounds: null,
        target: target,
        zoom: _singlePointZoom,
      );
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(target, _singlePointZoom),
      );
      return;
    }

    final bounds = _calculateBounds(points);
    if (bounds == null) {
      return;
    }

    _logCameraDebug(
      pointCount: points.length,
      bounds: bounds,
      target: points.first,
      zoom: null,
    );

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, _boundsPadding),
      );
    } on Exception catch (error) {
      if (kDebugMode) {
        debugPrint('[WorkoutRouteMap] bounds fit failed (attempt $attempt): $error');
      }
      if (attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 180 * (attempt + 1)));
        if (mounted) {
          await _fitRoute(attempt: attempt + 1);
        }
        return;
      }

      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 14),
      );
    }
  }

  void _scheduleCameraFit() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (mounted && !_userInteracted) {
        await _fitRoute();
      }
    });
  }

  void _logRouteDebug() {
    if (!kDebugMode) {
      return;
    }

    final points = _routePoints;
    debugPrint('[WorkoutRouteMap] workoutId=${widget.workout.id}');
    debugPrint('[WorkoutRouteMap] routePoints=${points.length}');
    if (points.isNotEmpty) {
      debugPrint('[WorkoutRouteMap] first=${points.first.latitude},${points.first.longitude}');
      debugPrint('[WorkoutRouteMap] last=${points.last.latitude},${points.last.longitude}');
      final bounds = _calculateBounds(points);
      if (bounds != null) {
        debugPrint(
          '[WorkoutRouteMap] bounds='
          '(${bounds.southwest.latitude},${bounds.southwest.longitude}) → '
          '(${bounds.northeast.latitude},${bounds.northeast.longitude})',
        );
      }
    }
  }

  void _logCameraDebug({
    required int pointCount,
    required LatLngBounds? bounds,
    required LatLng target,
    required double? zoom,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[WorkoutRouteMap] cameraFit points=$pointCount target=$target zoom=$zoom');
    if (bounds != null) {
      debugPrint('[WorkoutRouteMap] cameraBounds=$bounds padding=$_boundsPadding');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_routePoints.isEmpty) {
      return _EmptyRouteState(fade: _fadeController);
    }

    final initialTarget = _routePoints.first;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: AppColorPalette.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppBorderRadius.radiusXl,
          child: GoogleMap(
            key: ValueKey('workout_map_${_loadedWorkoutId ?? 0}'),
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: _routePoints.length <= 1 ? _singlePointZoom : 14,
            ),
            style: MapStyles.forContext(context),
            myLocationEnabled: false,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
            polylines: _polylines,
            markers: _markers,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (controller) {
              _controller = controller;
              _scheduleCameraFit();
            },
            onCameraMoveStarted: () {
              _userInteracted = true;
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyRouteState extends StatelessWidget {
  const _EmptyRouteState({required this.fade});

  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: fade, curve: Curves.easeOutCubic),
      child: Container(
        height: 240,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColorPalette.darkCard.withValues(alpha: 0.92),
          borderRadius: AppBorderRadius.radiusXl,
          border: Border.all(
            color: AppColorPalette.darkCardElevated.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorPalette.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route_outlined,
              size: 42,
              color: AppColorPalette.grey500.withValues(alpha: 0.85),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No GPS route available for this activity.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColorPalette.grey400,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
