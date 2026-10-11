enum StockTransferFilter {
  awaitingReceipt,
  onVehicle,
  awaitingWarehouse,
  completed,
}

enum StockTransferStatus {
  awaitingReceipt,
  onVehicle,
  awaitingWarehouse,
  completed,
  receiptDiscrepancy;

  StockTransferFilter get filter => switch (this) {
    awaitingReceipt => StockTransferFilter.awaitingReceipt,
    onVehicle => StockTransferFilter.onVehicle,
    awaitingWarehouse => StockTransferFilter.awaitingWarehouse,
    completed || receiptDiscrepancy => StockTransferFilter.completed,
  };
}

class StockTransferModel {
  const StockTransferModel({
    required this.number,
    required this.sourceWarehouse,
    required this.destinationWarehouse,
    required this.vehicle,
    required this.representative,
    required this.itemCount,
    required this.totalQuantity,
    required this.createdAt,
    required this.expectedArrival,
    required this.status,
  });

  final String number;
  final String sourceWarehouse;
  final String destinationWarehouse;
  final String vehicle;
  final String representative;
  final int itemCount;
  final int totalQuantity;
  final DateTime createdAt;
  final DateTime expectedArrival;
  final StockTransferStatus status;
}
