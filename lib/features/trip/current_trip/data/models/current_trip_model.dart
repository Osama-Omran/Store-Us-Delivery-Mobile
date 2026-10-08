class CurrentTripModel {
  const CurrentTripModel({
    required this.id,
    required this.vehicleName,
    required this.plateNumber,
    required this.driverName,
    required this.warehouseName,
    required this.totalOrders,
    required this.handledOrders,
    required this.collectedAmount,
  });

  final String id;
  final String vehicleName;
  final String plateNumber;
  final String driverName;
  final String warehouseName;
  final int totalOrders;
  final int handledOrders;
  final num collectedAmount;

  int get remainingOrders => handledOrders >= totalOrders
      ? 0
      : totalOrders - handledOrders;

  double get progress => totalOrders <= 0
      ? 0
      : (handledOrders / totalOrders).clamp(0.0, 1.0).toDouble();

  int get progressPercent => (progress * 100).round();
}
