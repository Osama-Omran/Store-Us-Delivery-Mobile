import 'dart:ui';

import 'package:storeus_delivery/core/theme/app_colors.dart';

/// Soft blue/gray road-map style matching the Store Us Delivery trip mockup.
/// Road and stop positions remain Google's actual map data.
final String tripMapStyle =
    '''
[
  {"elementType":"geometry","stylers":[{"color":"${_rgbHex(AppColors.blue4)}"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"${_rgbHex(AppColors.mapLabel)}"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"${_rgbHex(AppColors.mapLabelHalo)}"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"${_rgbHex(AppColors.mapRoad)}"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"${_rgbHex(AppColors.mapRoadBorder)}"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"${_rgbHex(AppColors.mapHighway)}"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"${_rgbHex(AppColors.mapWater)}"}]}
]
''';

String _rgbHex(Color color) =>
    '#${(color.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0')}';
