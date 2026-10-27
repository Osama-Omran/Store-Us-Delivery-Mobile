import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:storeus_delivery/features/trip/trip_map/presentation/utils/trip_map_style.dart';

void main() {
  test('palette-backed map style preserves the existing Google Maps rules', () {
    const previousStyle = '''
    [
      {"elementType":"geometry","stylers":[{"color":"#e1edff"}]},
      {"elementType":"labels.text.fill","stylers":[{"color":"#556d8e"}]},
      {"elementType":"labels.text.stroke","stylers":[{"color":"#f2f7ff"}]},
      {"featureType":"poi","stylers":[{"visibility":"off"}]},
      {"featureType":"transit","stylers":[{"visibility":"off"}]},
      {"featureType":"road","elementType":"geometry","stylers":[{"color":"#cbd7e6"}]},
      {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#d5dfec"}]},
      {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#b9cce2"}]},
      {"featureType":"water","elementType":"geometry","stylers":[{"color":"#b9ddf8"}]}
    ]
    ''';

    expect(jsonDecode(tripMapStyle), jsonDecode(previousStyle));
  });
}
