enum TripOrderStatus {
  delivered,
  rescheduled,
  partiallyDelivered,
  pending,
  cancelled,
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
    this.collectedAmount = 0,
  });

  final String id;
  final int stopNumber;
  final String customerName;
  final String address;
  final String phoneNumber;
  final num orderAmount;
  final TripOrderStatus status;
  final num collectedAmount;

  bool get isPending => status == TripOrderStatus.pending;
}
