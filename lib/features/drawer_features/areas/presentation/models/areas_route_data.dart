import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_order_model.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/trip_map/data/models/trip_map_stop.dart';

/// A presentation snapshot of the existing trip data; no operational rules.
class AreasRouteData {
  AreasRouteData({required this.trip, required List<TripOrderModel> orders})
    : orders = List.unmodifiable(
        (orders.indexed.toList()..sort((a, b) {
              final order = a.$2.stopNumber.compareTo(b.$2.stopNumber);
              return order == 0 ? a.$1.compareTo(b.$1) : order;
            }))
            .map((entry) => entry.$2),
      );

  final CurrentTripData trip;
  final List<TripOrderModel> orders;

  int get total => orders.length;
  int get finished => orders.where((order) => order.isHandled).length;
  int get remaining => total - finished;
  TripOrderModel? get nextStop =>
      orders.where((order) => order.isPending).firstOrNull;
  int get missingCoordinates =>
      orders.where((order) => !order.hasCoordinates).length;

  List<TripMapStop> get mapStops => orders
      .where((order) => order.hasCoordinates)
      .map(
        (order) => TripMapStop(
          order: order,
          location: LatLng(order.latitude!, order.longitude!),
        ),
      )
      .toList(growable: false);

  LatLng? get warehouseLocation {
    final lat = double.tryParse(trip.warehouse?.latitude ?? '');
    final lng = double.tryParse(trip.warehouse?.longitude ?? '');
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      return null;
    }
    return LatLng(lat, lng);
  }
}
