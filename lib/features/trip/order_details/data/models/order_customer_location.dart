
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

class OrderCustomerLocation {
  const OrderCustomerLocation({
    required this.name,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;

  bool get hasAddress => address.trim().isNotEmpty;

  bool get hasCoordinates =>
      latitude != null &&
          longitude != null &&
          latitude! >= -90 &&
          latitude! <= 90 &&
          longitude! >= -180 &&
          longitude! <= 180;

  bool get isComplete => hasAddress && hasCoordinates;

  factory OrderCustomerLocation.fromApi({
    required OrderDetailsData details,
    TripOrderData? tripOrder,
  }) {
    final customer = details.customer;
    final listCustomer = tripOrder?.customer;

    String firstNonEmpty(String? first, String? second) {
      if (first?.trim().isNotEmpty == true) {
        return first!.trim();
      }

      return second?.trim() ?? '';
    }

    final listLat = tripOrder?.latitude;
    final listLng = tripOrder?.longitude;

    return OrderCustomerLocation(
      name: firstNonEmpty(
        listCustomer?.name,
        customer?.name,
      ),
      phone: firstNonEmpty(
        listCustomer?.phone,
        customer?.phone,
      ),
      address: firstNonEmpty(
        tripOrder?.address,
        customer?.address,
      ),
      latitude: listLat != null && listLng != null
          ? listLat
          : customer?.latitude,
      longitude: listLat != null && listLng != null
          ? listLng
          : customer?.longitude,
    );
  }
}
