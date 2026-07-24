import 'package:flutter/material.dart';

import 'home_header.dart';

export 'home_header.dart' show HomeHeader;

/// Time-aware greeting with the user's name.
class GreetingSection extends StatelessWidget {
  const GreetingSection({
    required this.userName,
    super.key,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return HomeHeader(
      userName: userName,
      onProfileTap: () {},
    );
  }
}
