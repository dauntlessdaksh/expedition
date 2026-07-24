import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/bloc/activity_bloc.dart';
import '../../features/home/presentation/widgets/avatar_card.dart';
import '../../features/onboarding/data/repositories/onboarding_repository.dart';
import 'avatar_layout.dart';
import '../theme/expedition_colors.dart';
import '../router/route_constants.dart';
import '../services/haptic_service.dart';
import '../services/profile_sync_notifier.dart';
import 'bottom_navigation_bar.dart';
import 'main_navigation.dart';
import 'main_tab.dart';
import 'shell_tab_index_scope.dart';

/// Hosts the indexed tab stack and persistent floating bottom navigation.
class BottomNavigationShell extends StatefulWidget {
  const BottomNavigationShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<BottomNavigationShell> createState() => _BottomNavigationShellState();
}

class _BottomNavigationShellState extends State<BottomNavigationShell> {
  final _avatarHostKey = GlobalKey<PersistentAvatarHostState>();

  String _avatarGender = 'male';
  Rect? _avatarRect;

  @override
  void initState() {
    super.initState();
    profileSyncNotifier.addListener(_refreshAvatarGender);
    avatarLayoutNotifier.addListener(_scheduleAvatarLayoutUpdate);
    _refreshAvatarGender();
    _scheduleAvatarLayoutUpdate();
  }

  @override
  void dispose() {
    profileSyncNotifier.removeListener(_refreshAvatarGender);
    avatarLayoutNotifier.removeListener(_scheduleAvatarLayoutUpdate);
    super.dispose();
  }

  void _scheduleAvatarLayoutUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateAvatarLayout());
  }

  @override
  void didUpdateWidget(covariant BottomNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _refreshAvatarGender();
    }
    _scheduleAvatarLayoutUpdate();
  }

  Future<void> _refreshAvatarGender() async {
    try {
      final profile =
          await context.read<OnboardingRepository>().getUserProfile();
      if (!mounted) return;
      final gender = profile?.gender ?? 'male';
      if (gender != _avatarGender) {
        setState(() => _avatarGender = gender);
      }
    } on Exception {
      // Keep the last known gender.
    }
  }

  void _updateAvatarLayout() {
    final context = avatarLayoutKey.currentContext;
    if (context == null || !mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final offset = box.localToGlobal(Offset.zero);
    final rect = offset & box.size;
    if (rect == _avatarRect) return;

    setState(() {
      _avatarRect = rect;
    });
  }

  bool _isProfileOpen(String location) {
    return location.contains(RouteConstants.profile);
  }

  bool _isHomeOverlayOpen(String location) {
    return _isProfileOpen(location) ||
        location.contains(RouteConstants.settings) ||
        location.contains(RouteConstants.gamification);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return BlocBuilder<ActivityBloc, ActivityState>(
      buildWhen: (previous, current) =>
          previous.isSessionActive != current.isSessionActive,
      builder: (context, activityState) {
        final showBottomNav = MainNavigation.shouldShowBottomNav(location) &&
            !activityState.isSessionActive;
        final isHomeTab =
            widget.navigationShell.currentIndex == MainTab.home.branchIndex;
        final isActivityTab =
            widget.navigationShell.currentIndex == MainTab.activity.branchIndex;

        final profileOpen = _isProfileOpen(location);
        final homeOverlayOpen = _isHomeOverlayOpen(location);
        final avatarSuspended = isActivityTab ||
            activityState.isSessionActive ||
            profileOpen ||
            homeOverlayOpen;
        final avatarVisible = isHomeTab && !homeOverlayOpen;
        final hasAvatarRect = _avatarRect != null;

        if (isHomeTab) {
          _scheduleAvatarLayoutUpdate();
        }

        return ShellTabIndexScope(
          currentIndex: widget.navigationShell.currentIndex,
          child: Builder(
            builder: (context) {
              final colors = context.expeditionColors;

              return Scaffold(
                backgroundColor: colors.scaffoldBackground,
                extendBody: showBottomNav,
                body: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: showBottomNav
                        ? MainNavigation.bottomNavReservedHeight
                        : 0,
                  ),
                  child: widget.navigationShell,
                ),
                if (!avatarSuspended)
                  Positioned(
                    left: hasAvatarRect ? _avatarRect!.left : -10000,
                    top: hasAvatarRect ? _avatarRect!.top : -10000,
                    width: hasAvatarRect ? _avatarRect!.width : 1,
                    height: hasAvatarRect ? _avatarRect!.height : 1,
                    child: PersistentAvatarHost(
                      key: _avatarHostKey,
                      gender: _avatarGender,
                      suspended: avatarSuspended,
                      visible: avatarVisible && hasAvatarRect,
                      compact: true,
                      scale: 1.15,
                    ),
                  ),
                if (showBottomNav)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ExpeditionBottomNavigationBar(
                      currentIndex: widget.navigationShell.currentIndex,
                      onTabSelected: (index) {
                        if (index != widget.navigationShell.currentIndex) {
                          HapticService.tabChanged();
                        }
                        widget.navigationShell.goBranch(
                          index,
                          initialLocation:
                              index == widget.navigationShell.currentIndex,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
            },
          ),
        );
      },
    );
  }
}
