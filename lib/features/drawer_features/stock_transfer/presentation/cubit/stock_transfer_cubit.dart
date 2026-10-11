import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/sample/sample_stock_transfers.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_state.dart';

class StockTransferCubit extends Cubit<StockTransferState> {
  factory StockTransferCubit({
    List<StockTransferModel>? transfers,
    DateTime? now,
  }) {
    final referenceDate = now ?? DateTime.now();
    return StockTransferCubit._(
      StockTransferState(
        transfers: List.unmodifiable(
          transfers ?? buildSampleStockTransfers(now: referenceDate),
        ),
        referenceDate: referenceDate,
      ),
    );
  }

  StockTransferCubit._(super.initialState);

  static StockTransferCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // ======= Transfer Filters ======= //
  void selectFilter(StockTransferFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }
}
