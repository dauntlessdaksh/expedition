import 'package:flutter/foundation.dart';

/// Ensures only one 3D avatar WebView is active at a time across the app.
///
/// Platform views (WebView + Google Maps) are expensive on Android; running
/// multiple avatar viewers simultaneously causes OOM and crashes.
final avatarHostLock = ValueNotifier<String?>(null);

abstract final class AvatarLifecycle {
  static bool get isLocked => avatarHostLock.value != null;

  static void acquire(String owner) {
    avatarHostLock.value = owner;
  }

  static void release(String owner) {
    if (avatarHostLock.value == owner) {
      avatarHostLock.value = null;
    }
  }
}

/// Tracks whether a GLB asset has been loaded at least once this session so
/// remounts can skip artificial settle delays.
abstract final class AvatarPreloadCache {
  static final Set<String> _loadedAssets = <String>{};

  static bool hasLoaded(String assetPath) => _loadedAssets.contains(assetPath);

  static void markLoaded(String assetPath) {
    _loadedAssets.add(assetPath);
  }
}
