import 'package:expedition/core/router/route_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteConstants', () {
    test('profile and gamification paths are nested under home', () {
      expect(RouteConstants.profilePath, '/home/profile');
      expect(RouteConstants.gamificationPath, '/home/gamification');
    });

    test('history detail path includes workout id', () {
      expect(RouteConstants.historyDetailPath(42), '/history/42');
    });
  });
}
