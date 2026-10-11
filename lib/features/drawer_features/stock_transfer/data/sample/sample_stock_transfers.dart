import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';

List<StockTransferModel> buildSampleStockTransfers({DateTime? now}) {
  final reference = now ?? DateTime.now();

  DateTime at(int daysAgo, int hour, int minute) => DateTime(
    reference.year,
    reference.month,
    reference.day - daysAgo,
    hour,
    minute,
  );

  StockTransferModel transfer({
    required String number,
    String source = 'مخزن الجيزة الرئيسي',
    required String destination,
    required int itemCount,
    required int quantity,
    required DateTime createdAt,
    required DateTime expectedArrival,
    required StockTransferStatus status,
  }) => StockTransferModel(
    number: number,
    sourceWarehouse: source,
    destinationWarehouse: destination,
    vehicle: 'سوزوكي فان - أ ب ج 1234',
    representative: 'أحمد محمد',
    itemCount: itemCount,
    totalQuantity: quantity,
    createdAt: createdAt,
    expectedArrival: expectedArrival,
    status: status,
  );

  return List.unmodifiable([
    transfer(
      number: 'TR-0102',
      destination: 'مخزن 6 أكتوبر',
      itemCount: 3,
      quantity: 90,
      createdAt: at(0, 8, 30),
      expectedArrival: at(0, 12, 0),
      status: StockTransferStatus.awaitingReceipt,
    ),
    transfer(
      number: 'TR-0103',
      destination: 'مخزن المهندسين',
      itemCount: 1,
      quantity: 50,
      createdAt: at(0, 9, 0),
      expectedArrival: at(0, 14, 0),
      status: StockTransferStatus.awaitingReceipt,
    ),
    transfer(
      number: 'TR-0099',
      source: 'مخزن 6 أكتوبر',
      destination: 'مخزن الجيزة الرئيسي',
      itemCount: 2,
      quantity: 40,
      createdAt: at(0, 7, 10),
      expectedArrival: at(0, 11, 0),
      status: StockTransferStatus.onVehicle,
    ),
    transfer(
      number: 'TR-0095',
      destination: 'مخزن الهرم',
      itemCount: 1,
      quantity: 30,
      createdAt: at(1, 15, 0),
      expectedArrival: at(1, 17, 0),
      status: StockTransferStatus.awaitingWarehouse,
    ),
    transfer(
      number: 'TR-0090',
      source: 'مخزن المهندسين',
      destination: 'مخزن الجيزة الرئيسي',
      itemCount: 1,
      quantity: 20,
      createdAt: at(1, 10, 0),
      expectedArrival: at(1, 12, 0),
      status: StockTransferStatus.completed,
    ),
    transfer(
      number: 'TR-0088',
      destination: 'مخزن 6 أكتوبر',
      itemCount: 1,
      quantity: 15,
      createdAt: at(2, 8, 0),
      expectedArrival: at(2, 12, 0),
      status: StockTransferStatus.receiptDiscrepancy,
    ),
  ]);
}
