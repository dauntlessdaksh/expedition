import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/haptic_service.dart';
import '../../data/models/activity_type.dart';

/// Large circular Start button — single tap to begin.
class CircularStartButton extends StatefulWidget {
  const CircularStartButton({
    required this.onPressed,
    required this.enabled,
    super.key,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  State<CircularStartButton> createState() => _CircularStartButtonState();
}

class _CircularStartButtonState extends State<CircularStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 88.0;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: 'Start workout',
      child: GestureDetector(
        onTap: widget.enabled
            ? () {
                HapticService.lightImpact();
                widget.onPressed();
              }
            : null,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final pulse = 1 + (_pulseController.value * 0.06);

            return SizedBox(
              width: size + 24,
              height: size + 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.enabled)
                    Transform.scale(
                      scale: pulse,
                      child: Container(
                        width: size + 16,
                        height: size + 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColorPalette.primary.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.enabled
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorPalette.accentGradientStart,
                                AppColorPalette.accentGradientEnd,
                              ],
                            )
                          : null,
                      color: widget.enabled
                          ? null
                          : AppColorPalette.darkCardElevated,
                      boxShadow: widget.enabled
                          ? [
                              BoxShadow(
                                color: AppColorPalette.primary
                                    .withValues(alpha: 0.55),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        widget.enabled ? 'Start' : '…',
                        style: TextStyle(
                          color: widget.enabled
                              ? AppColorPalette.white
                              : AppColorPalette.grey500,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Pre-start controls: activity (left), start (center), settings (right).
class ActivityPreStartControls extends StatelessWidget {
  const ActivityPreStartControls({
    required this.activityType,
    required this.enabled,
    required this.onActivityTap,
    required this.onStart,
    required this.onSettingsTap,
    super.key,
  });

  final ActivityType activityType;
  final bool enabled;
  final VoidCallback onActivityTap;
  final VoidCallback onStart;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ActivityFloatingButton(
          icon: activityType.icon,
          iconColor: activityType.accentColor,
          onTap: onActivityTap,
          size: 56,
        ),
        const SizedBox(width: 28),
        CircularStartButton(
          enabled: enabled,
          onPressed: onStart,
        ),
        const SizedBox(width: 28),
        ActivityFloatingButton(
          icon: Icons.settings_rounded,
          onTap: onSettingsTap,
          size: 56,
        ),
      ],
    );
  }
}

/// Large circular Start button with pulse and circular hold progress.
class CircularHoldStartButton extends StatefulWidget {
  const CircularHoldStartButton({
    required this.onConfirmed,
    required this.enabled,
    this.holdDuration = const Duration(milliseconds: 1000),
    super.key,
  });

  final VoidCallback onConfirmed;
  final bool enabled;
  final Duration holdDuration;

  @override
  State<CircularHoldStartButton> createState() =>
      _CircularHoldStartButtonState();
}

class _CircularHoldStartButtonState extends State<CircularHoldStartButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _holdController;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _holdController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_confirmed) {
          _confirmed = true;
          HapticService.heavyImpact();
          widget.onConfirmed();
        }
      });
    _holdController.duration = widget.holdDuration;
  }

  @override
  void didUpdateWidget(CircularHoldStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _holdController.duration = widget.holdDuration;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _startHold() {
    if (!widget.enabled || _confirmed) return;
    _confirmed = false;
    HapticService.lightImpact();
    _holdController.forward(from: 0);
  }

  void _cancelHold() {
    if (_holdController.status == AnimationStatus.completed) return;
    _holdController.reset();
    _confirmed = false;
  }

  @override
  Widget build(BuildContext context) {
    const size = 88.0;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: 'Hold to start workout',
      child: Listener(
        onPointerDown: (_) => _startHold(),
        onPointerUp: (_) => _cancelHold(),
        onPointerCancel: (_) => _cancelHold(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _holdController]),
          builder: (context, _) {
            final pulse = 1 + (_pulseController.value * 0.06);
            final hold = _holdController.value;
            final isHolding = hold > 0 && hold < 1;

            return SizedBox(
              width: size + 24,
              height: size + 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.enabled && !isHolding)
                    Transform.scale(
                      scale: pulse,
                      child: Container(
                        width: size + 16,
                        height: size + 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColorPalette.primary.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  if (isHolding || hold >= 1)
                    SizedBox(
                      width: size + 12,
                      height: size + 12,
                      child: CircularProgressIndicator(
                        value: hold.clamp(0, 1),
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        color: AppColorPalette.white,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  Transform.scale(
                    scale: widget.enabled ? (isHolding ? 0.96 : 1) : 1,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.enabled
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColorPalette.accentGradientStart,
                                  AppColorPalette.accentGradientEnd,
                                ],
                              )
                            : null,
                        color: widget.enabled
                            ? null
                            : AppColorPalette.darkCardElevated,
                        boxShadow: widget.enabled
                            ? [
                                BoxShadow(
                                  color: AppColorPalette.primary
                                      .withValues(alpha: 0.55),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          widget.enabled ? 'Start' : '…',
                          style: TextStyle(
                            color: widget.enabled
                                ? AppColorPalette.white
                                : AppColorPalette.grey500,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Floating circular icon button used on the activity map overlay.
class ActivityFloatingButton extends StatelessWidget {
  const ActivityFloatingButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
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
            color: backgroundColor ??
                AppColorPalette.darkCard.withValues(alpha: 0.92),
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
            color: iconColor ?? AppColorPalette.white,
            size: size * 0.46,
          ),
        ),
      ),
    );
  }
}

/// Compact floating chip for goals on the activity screen.
class ActivityGoalChip extends StatelessWidget {
  const ActivityGoalChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColorPalette.darkCard.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Spring-animated modal bottom sheet wrapper.
Future<T?> showActivityBottomSheet<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColorPalette.darkCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColorPalette.grey600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: child,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
