import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'main_tab.dart';

/// Liquid Glass floating bottom navigation inspired by iOS premium aesthetics.
class ExpeditionBottomNavigationBar extends StatefulWidget {
  const ExpeditionBottomNavigationBar({
    required this.currentIndex,
    required this.onTabSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  static const barHeight = 72.0;
  static const barRadius = 36.0;
  static const horizontalInset = AppSpacing.lg;

  // rgba(15, 15, 18, 0.72)
  static const glassBackground = Color(0xB80F0F12);
  // rgba(255, 255, 255, 0.08)
  static const glassBorder = Color(0x14FFFFFF);
  // rgba(255, 255, 255, 0.60)
  static const inactiveIcon = Color(0x99FFFFFF);

  @override
  State<ExpeditionBottomNavigationBar> createState() =>
      _ExpeditionBottomNavigationBarState();
}

class _ExpeditionBottomNavigationBarState
    extends State<ExpeditionBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _pillController;
  late AnimationController _blurController;
  late double _pillIndex;

  static const _spring = SpringDescription(
    mass: 0.8,
    stiffness: 340,
    damping: 24,
  );

  @override
  void initState() {
    super.initState();
    _pillIndex = widget.currentIndex.toDouble();
    _pillController = AnimationController.unbounded(vsync: this)
      ..value = _pillIndex;
    _pillController.addListener(() {
      if (mounted) {
        setState(() => _pillIndex = _pillController.value);
      }
    });
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant ExpeditionBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animatePillTo(widget.currentIndex);
      _blurController
        ..forward(from: 0.85)
        ..animateTo(1, curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _pillController.dispose();
    _blurController.dispose();
    super.dispose();
  }

  void _animatePillTo(int index) {
    _pillController.stop();
    final simulation = SpringSimulation(
      _spring,
      _pillController.value,
      index.toDouble(),
      _pillController.velocity,
    );
    _pillController.animateWith(simulation);
  }

  void _onTabTap(int index) {
    if (index == widget.currentIndex) return;
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        ExpeditionBottomNavigationBar.horizontalInset,
        0,
        ExpeditionBottomNavigationBar.horizontalInset,
        bottomInset > 0 ? bottomInset * 0.35 + AppSpacing.sm : AppSpacing.md,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ExpeditionBottomNavigationBar.barRadius),
          boxShadow: [
            BoxShadow(
              color: AppColorPalette.black.withValues(alpha: 0.55),
              blurRadius: 40,
              offset: const Offset(0, 18),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: AppColorPalette.primary.withValues(alpha: 0.06),
              blurRadius: 48,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(ExpeditionBottomNavigationBar.barRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 28 * _blurController.value,
              sigmaY: 28 * _blurController.value,
            ),
            child: Container(
              height: ExpeditionBottomNavigationBar.barHeight,
              decoration: BoxDecoration(
                color: ExpeditionBottomNavigationBar.glassBackground,
                borderRadius: BorderRadius.circular(
                  ExpeditionBottomNavigationBar.barRadius,
                ),
                border: Border.all(
                  color: ExpeditionBottomNavigationBar.glassBorder,
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColorPalette.white.withValues(alpha: 0.11),
                    AppColorPalette.white.withValues(alpha: 0.03),
                    AppColorPalette.black.withValues(alpha: 0.08),
                  ],
                  stops: const [0, 0.22, 1],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / MainTab.values.length;
                  const pillInset = 6.0;
                  final pillWidth = tabWidth - pillInset * 2;
                  final pillLeft = _pillIndex * tabWidth + pillInset;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: pillLeft,
                        top: pillInset,
                        bottom: pillInset,
                        width: pillWidth,
                        child: _LiquidPill(width: pillWidth),
                      ),
                      Row(
                        children: MainTab.values.map((tab) {
                          final isSelected =
                              widget.currentIndex == tab.branchIndex;
                          return Expanded(
                            child: _LiquidNavItem(
                              tab: tab,
                              isSelected: isSelected,
                              onTap: () => _onTabTap(tab.branchIndex),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Morphing red glow capsule beneath the active tab.
class _LiquidPill extends StatelessWidget {
  const _LiquidPill({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorPalette.primary.withValues(alpha: 0.28),
            AppColorPalette.primary.withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.35),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primary.withValues(alpha: 0.42),
            blurRadius: 20,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColorPalette.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColorPalette.white.withValues(alpha: 0.14),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidNavItem extends StatelessWidget {
  const _LiquidNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final MainTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: AppColorPalette.primary.withValues(alpha: 0.12),
        highlightColor: AppColorPalette.white.withValues(alpha: 0.04),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: isSelected ? 1 : 0,
                  ),
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  builder: (context, t, child) {
                    final scale = lerpDouble(1, 1.12, t)!;
                    final lift = lerpDouble(0, -3, t)!;
                    return Transform.translate(
                      offset: Offset(0, lift),
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    tab.icon,
                    size: 24,
                    color: isSelected
                        ? AppColorPalette.white
                        : ExpeditionBottomNavigationBar.inactiveIcon,
                  ),
                ),
                ClipRect(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    heightFactor: isSelected ? 1 : 0,
                    alignment: Alignment.topCenter,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: isSelected ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColorPalette.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
