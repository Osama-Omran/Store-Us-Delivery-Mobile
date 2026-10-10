
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';

enum TripOrderStatus {
  delivered,
  rescheduled,
  partiallyDelivered,
  pending,
  cancelled,
  unknown,
}

class TripOrderModel {
  const TripOrderModel({
    required this.id,
    required this.stopNumber,
    required this.customerName,
    required this.address,
    required this.phoneNumber,
    required this.orderAmount,
    required this.status,
    this.apiId,
    this.latitude,
    this.longitude,
    this.paymentStatus,
    this.rawDeliveryStatus,
    this.collectedAmount = 0,
  });

  // Sales Order number displayed on the card.
  final String id;

  // Numeric Trip Order ID from the API.
  final int? apiId;

  final int stopNumber;
  final String customerName;
  final String address;
  final String phoneNumber;
  final num? orderAmount;

  final TripOrderStatus status;
  final String? rawDeliveryStatus;
  final String? paymentStatus;

  final double? latitude;
  final double? longitude;

  // Only for flows where a collected amount is actually known.
  final num collectedAmount;

  bool get isPending => status == TripOrderStatus.pending;

  bool get isHandled => switch (status) {
    TripOrderStatus.delivered ||
    TripOrderStatus.partiallyDelivered ||
    TripOrderStatus.rescheduled ||
    TripOrderStatus.cancelled => true,
    _ => false,
  };

  bool get hasPhone => phoneNumber.trim().isNotEmpty;

  bool get hasCoordinates =>
      latitude != null &&
          longitude != null &&
          latitude! >= -90 &&
          latitude! <= 90 &&
          longitude! >= -180 &&
          longitude! <= 180;

  bool get isPaymentCollected {
    final payment = paymentStatus?.toUpperCase();

    return payment == 'PAID' || payment == 'COLLECTED';
  }

  factory TripOrderModel.fromApi(TripOrderData data) {
    final rawStatus =
    data.deliveryStatus.trim().toUpperCase();

    return TripOrderModel(
      id: data.salesOrder,
      apiId: data.id,
      stopNumber: data.stopOrder,
      customerName: data.customer?.name?.trim().isNotEmpty == true
          ? data.customer!.name!
          : '—',
      address: data.address?.trim() ?? '',
      phoneNumber: data.customer?.phone?.trim() ?? '',
      orderAmount: data.orderTotal,
      status: _mapDeliveryStatus(rawStatus),
      rawDeliveryStatus: rawStatus,
      paymentStatus: data.paymentStatus,
      latitude: data.latitude,
      longitude: data.longitude,
    );
  }

  static TripOrderStatus _mapDeliveryStatus(String status) {
    return switch (status) {
      'PENDING' => TripOrderStatus.pending,

      'DELIVERED' ||
      'COMPLETED' ||
      'FULLY_DELIVERED' ||
      'DELIVERED_FULLY' => TripOrderStatus.delivered,

      'PARTIAL' ||
      'PARTIALLY_DELIVERED' ||
      'PARTIAL_DELIVERED' ||
      'DELIVERED_PARTIALLY' =>
      TripOrderStatus.partiallyDelivered,

      'RESCHEDULED' => TripOrderStatus.rescheduled,

      'CANCELLED' ||
      'CANCELED' => TripOrderStatus.cancelled,

      _ => TripOrderStatus.unknown,
    };
  }
}
