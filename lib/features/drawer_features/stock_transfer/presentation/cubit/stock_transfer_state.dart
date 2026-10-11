import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';

class StockTransferState {
  const StockTransferState({
    required this.transfers,
    required this.referenceDate,
    this.filter = StockTransferFilter.awaitingReceipt,
  });

  final List<StockTransferModel> transfers;
  final DateTime referenceDate;
  final StockTransferFilter filter;

  int countFor(StockTransferFilter filter) =>
      transfers.where((transfer) => transfer.status.filter == filter).length;

  List<StockTransferModel> get filteredTransfers => List.unmodifiable(
    transfers.where((transfer) => transfer.status.filter == filter),
  );

  StockTransferState copyWith({StockTransferFilter? filter}) =>
      StockTransferState(
        transfers: transfers,
        referenceDate: referenceDate,
        filter: filter ?? this.filter,
      );
}
