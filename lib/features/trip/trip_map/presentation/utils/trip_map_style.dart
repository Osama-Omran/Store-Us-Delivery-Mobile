/// Soft blue/gray road-map style matching the Store Us Delivery trip mockup.
/// Road and stop positions remain Google's actual map data.
const tripMapStyle = '''
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
