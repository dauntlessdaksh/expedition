/// Premium dark styling for Google Maps.
abstract final class MapDarkStyle {
  static const String json = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0A0A0F"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#9CA3AF"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0A0A0F"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#374151"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#14141F"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1C1C2E"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#242438"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1F2937"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#374151"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#14141F"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0F172A"}]}
]
''';
}
