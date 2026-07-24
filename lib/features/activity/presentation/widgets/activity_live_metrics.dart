import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../bloc/activity_bloc.dart';
import '../utils/activity_formatters.dart';

/// Premium floating panel showing live workout metrics during tracking.
class ActivityLiveMetricsPanel extends StatelessWidget {
  const ActivityLiveMetricsPanel({
    required this.state,
    super.key,
  });

  final ActivityState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      offset: state.showWorkoutPanel ? Offset.zero : const Offset(0, 0.15),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: state.showWorkoutPanel ? 1 : 0,
        child: IgnorePointer(
          ignoring: !state.showWorkoutPanel,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColorPalette.darkCard.withValues(alpha: 0.94),
              borderRadius: AppBorderRadius.radiusXxl,
              border: Border.all(
                color: AppColorPalette.darkCardElevated.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorPalette.black.withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ActivityFormatters.distanceKm(state.distanceMeters),
                  style: const TextStyle(
                    color: AppColorPalette.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'DISTANCE',
                  style: TextStyle(
                    color: AppColorPalette.grey500.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    _MetricCell(
                      label: 'Altitude',
                      value: ActivityFormatters.elevationMeters(
                        state.currentAltitudeMeters,
                      ),
                    ),
                    _MetricCell(
                      label: 'Speed',
                      value: ActivityFormatters.speedKmh(state.currentSpeedMps),
                    ),
                    _MetricCell(
                      label: 'Calories',
                      value: '${state.activeCalories}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColorPalette.grey500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColorPalette.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live workout timer that ticks every second without centisecond jitter.
class ActivityWorkoutTimer extends StatefulWidget {
  const ActivityWorkoutTimer({
    required this.duration,
    required this.isRunning,
    this.style,
    super.key,
  });

  final Duration duration;
  final bool isRunning;
  final TextStyle? style;

  @override
  State<ActivityWorkoutTimer> createState() => _ActivityWorkoutTimerState();
}

class _ActivityWorkoutTimerState extends State<ActivityWorkoutTimer> {
  Timer? _timer;
  late Duration _displayDuration;
  late Duration _baselineDuration;
  DateTime? _baselineStartedAt;

  static const _timerStyle = TextStyle(
    color: Color(0xFFFFD54F),
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  void initState() {
    super.initState();
    _applyDuration(widget.duration, restartTicker: widget.isRunning);
  }

  @override
  void didUpdateWidget(ActivityWorkoutTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isRunning) {
      if (oldWidget.isRunning || oldWidget.duration != widget.duration) {
        _applyDuration(widget.duration, restartTicker: false);
      }
      return;
    }

    if (!oldWidget.isRunning) {
      _applyDuration(widget.duration, restartTicker: true);
      return;
    }

    // Keep ticking locally; only resync if the bloc drifts by 2+ seconds.
    final drift =
        (widget.duration.inSeconds - _displayDuration.inSeconds).abs();
    if (drift >= 2) {
      _applyDuration(widget.duration, restartTicker: true);
    }
  }

  void _applyDuration(Duration duration, {required bool restartTicker}) {
    _baselineDuration = duration;
    _displayDuration = Duration(seconds: duration.inSeconds);

    _timer?.cancel();
    _timer = null;
    _baselineStartedAt = null;

    if (!restartTicker) {
      return;
    }

    _baselineStartedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    if (!mounted || _baselineStartedAt == null) {
      return;
    }

    final elapsed = DateTime.now().difference(_baselineStartedAt!);
    final next = Duration(
      seconds: (_baselineDuration + elapsed).inSeconds,
    );

    if (next != _displayDuration) {
      setState(() => _displayDuration = next);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        ActivityFormatters.duration(_displayDuration),
        textAlign: TextAlign.center,
        style: widget.style ?? _timerStyle,
      ),
    );
  }
}

/// Bottom tracking controls: cancel, pause/resume, lock.
class ActivityTrackingControls extends StatelessWidget {
  const ActivityTrackingControls({
    required this.isPaused,
    required this.duration,
    required this.onCancel,
    required this.onPauseResume,
    required this.onLock,
    this.voiceEnabled = false,
    this.onMusicTap,
    this.onMuteTap,
    super.key,
  });

  final bool isPaused;
  final Duration duration;
  final bool voiceEnabled;
  final VoidCallback onCancel;
  final VoidCallback onPauseResume;
  final VoidCallback onLock;
  final VoidCallback? onMusicTap;
  final VoidCallback? onMuteTap;

  @override
  Widget build(BuildContext context) {
    return ActivityWorkoutControlPanel(
      topRow: Row(
        children: [
          _WorkoutUtilityButton(
            icon: Icons.library_music_rounded,
            iconColor: const Color(0xFF4ADE80),
            onTap: onMusicTap,
          ),
          Expanded(
            child: ActivityWorkoutTimer(
              duration: duration,
              isRunning: !isPaused,
            ),
          ),
          _WorkoutUtilityButton(
            icon: voiceEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            iconColor: voiceEnabled
                ? AppColorPalette.primaryLight
                : AppColorPalette.grey400,
            onTap: onMuteTap,
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _WorkoutActionButton(
            icon: Icons.close_rounded,
            onTap: onCancel,
            size: 64,
          ),
          const SizedBox(width: 28),
          _WorkoutActionButton(
            icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            onTap: onPauseResume,
            size: 76,
          ),
          const SizedBox(width: 28),
          _WorkoutActionButton(
            icon: Icons.lock_outline_rounded,
            onTap: onLock,
            size: 64,
          ),
        ],
      ),
    );
  }
}

/// Shared dark bottom panel used during active workouts.
class ActivityWorkoutControlPanel extends StatelessWidget {
  const ActivityWorkoutControlPanel({
    required this.body,
    this.topRow,
    super.key,
  });

  final Widget? topRow;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141416).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.black.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColorPalette.grey600.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (topRow != null) ...[
            const SizedBox(height: 18),
            topRow!,
          ],
          const SizedBox(height: 22),
          body,
        ],
      ),
    );
  }
}

class _WorkoutUtilityButton extends StatelessWidget {
  const _WorkoutUtilityButton({
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColorPalette.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _WorkoutActionButton extends StatelessWidget {
  const _WorkoutActionButton({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2E),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColorPalette.white,
            size: size * 0.38,
          ),
        ),
      ),
    );
  }
}

/// Full-screen countdown overlay before tracking begins.
class ActivityCountdownOverlay extends StatelessWidget {
  const ActivityCountdownOverlay({
    required this.seconds,
    super.key,
  });

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorPalette.black.withValues(alpha: 0.82),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(seconds),
        tween: Tween(begin: 1.35, end: 1),
        duration: const Duration(milliseconds: 550),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Text(
          '$seconds',
          style: const TextStyle(
            color: AppColorPalette.primary,
            fontSize: 140,
            fontWeight: FontWeight.w800,
            letterSpacing: -4,
            height: 1,
            shadows: [
              Shadow(
                color: Color(0x66E53935),
                blurRadius: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lock screen overlay during tracking.
class ActivityLockOverlay extends StatelessWidget {
  const ActivityLockOverlay({
    required this.duration,
    required this.isPaused,
    required this.onUnlock,
    this.voiceEnabled = false,
    this.onMusicTap,
    this.onMuteTap,
    super.key,
  });

  final Duration duration;
  final bool isPaused;
  final bool voiceEnabled;
  final VoidCallback onUnlock;
  final VoidCallback? onMusicTap;
  final VoidCallback? onMuteTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              color: AppColorPalette.black.withValues(alpha: 0.18),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: ActivityWorkoutControlPanel(
              topRow: Row(
                children: [
                  _WorkoutUtilityButton(
                    icon: Icons.library_music_rounded,
                    iconColor: const Color(0xFF4ADE80),
                    onTap: onMusicTap,
                  ),
                  Expanded(
                    child: ActivityWorkoutTimer(
                      duration: duration,
                      isRunning: !isPaused,
                      style: const TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        height: 1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  _WorkoutUtilityButton(
                    icon: voiceEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    iconColor: voiceEnabled
                        ? AppColorPalette.primaryLight
                        : AppColorPalette.grey400,
                    onTap: onMuteTap,
                  ),
                ],
              ),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: onUnlock,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColorPalette.black.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: AppColorPalette.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Hold to unlock',
                    style: TextStyle(
                      color: AppColorPalette.white.withValues(alpha: 0.82),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
