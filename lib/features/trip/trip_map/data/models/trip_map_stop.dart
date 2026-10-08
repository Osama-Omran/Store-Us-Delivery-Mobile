import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';

/// Coordinates must come from the order delivery location, not geocoded text.
class TripMapStop {
  const TripMapStop({
    required this.order,
    required this.location,
  });

  final TripOrderModel order;
  final LatLng location;

  String get id => order.id;
  int get number => order.stopNumber;
  String get name => order.customerName;
  String get address => order.address;
  TripOrderStatus get status => order.status;
  bool get isPending => order.isPending;
}
