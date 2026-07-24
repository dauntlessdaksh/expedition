import 'package:flutter/widgets.dart';

/// Global key used by the home hero to report avatar layout bounds.
final avatarLayoutKey = GlobalKey();

/// Notifies the navigation shell when avatar layout bounds may have changed.
final avatarLayoutNotifier = ValueNotifier<int>(0);

void notifyAvatarLayoutChanged() {
  avatarLayoutNotifier.value++;
}
