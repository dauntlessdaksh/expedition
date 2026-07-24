import 'package:flutter/foundation.dart';

/// Notifies listeners when profile/preferences change outside their screen.
final profileSyncNotifier = ValueNotifier<int>(0);

void notifyProfileChanged() {
  profileSyncNotifier.value++;
}
