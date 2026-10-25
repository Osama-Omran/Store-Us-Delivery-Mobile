import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfers_response.dart';

class StockTransferState {
  const StockTransferState({
    required this.referenceDate,
    this.transfers = const [],
    this.filter = StockTransferFilter.awaitingReceipt,
    this.meta,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  final List<StockTransferModel> transfers;
  final DateTime referenceDate;
  final StockTransferFilter filter;
  final StockTransferPageMeta? meta;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  bool get hasLoaded => meta != null;
  bool get hasMorePages => meta != null && !meta!.coversAll(transfers);

  // Null means an accurate TOTAL count cannot be proven from the loaded page(s).
  int? get pendingActionCount {
    if (error != null || meta?.coversAll(transfers) != true) return null;
    return transfers.where((transfer) => transfer.needsAction).length;
  }

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
        meta: meta,
        isLoading: isLoading,
        isRefreshing: isRefreshing,
        error: error,
      );
}
