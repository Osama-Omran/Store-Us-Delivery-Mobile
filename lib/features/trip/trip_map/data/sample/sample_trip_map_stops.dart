import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/sample/sample_current_trip.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';

/// DEMONSTRATION COORDINATES ONLY. Not verified customer addresses.
/// Never use these coordinates for production deliveries or navigation.
const _sampleCoordinates = <int, LatLng>{
  1: LatLng(30.0100, 31.1743),
  2: LatLng(29.9955, 31.1630),
  3: LatLng(30.0086, 31.1781),
  4: LatLng(30.0118, 31.2064),
  5: LatLng(30.0187, 31.1602),
  6: LatLng(30.0072, 31.1666),
  7: LatLng(30.0137, 31.2071),
  8: LatLng(30.0544, 31.2028),
  9: LatLng(30.0470, 31.2016),
  10: LatLng(30.0499, 31.1985),
  11: LatLng(30.0382, 31.2177),
  12: LatLng(30.0340, 31.2107),
};

final sampleTripMapStops = sampleTripOrders.map((order) {
  final coordinates = _sampleCoordinates[order.stopNumber]!;
  return TripMapStop(order: order, location: coordinates);
}).toList(growable: false);
