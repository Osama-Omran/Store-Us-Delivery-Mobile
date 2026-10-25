import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/domain/usecases/get_stock_transfers_usecase.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/presentation/cubit/stock_transfer_state.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfer_model.dart';

class StockTransferCubit extends Cubit<StockTransferState> {
  StockTransferCubit(this._usecase)
      : super(StockTransferState(referenceDate: DateTime.now()));

  final GetStockTransfersUsecase _usecase;
  DateTime? _lastLoadedAt;
  int _requestId = 0;

  static StockTransferCubit get(BuildContext context) =>
      BlocProvider.of<StockTransferCubit>(context);

  Future<void> load() async {
    if (isClosed || state.isLoading || state.isRefreshing) return;
    final requestId = ++_requestId;
    final previous = state;
    final alreadyLoaded = previous.hasLoaded;

    emit(StockTransferState(
      transfers: previous.transfers,
      referenceDate: previous.referenceDate,
      filter: previous.filter,
      meta: previous.meta,
      isLoading: !alreadyLoaded,
      isRefreshing: alreadyLoaded,
    ));

    final result = await _usecase.call();
    if (isClosed || requestId != _requestId) return;

    result.when(
      success: (response) {
        _lastLoadedAt = DateTime.now();
        emit(StockTransferState(
          transfers: response.transfers,
          referenceDate: DateTime.now(),
          filter: state.filter,
          meta: response.meta,
        ));
      },
      failure: (error) {
        emit(StockTransferState(
          transfers: previous.transfers,
          referenceDate: previous.referenceDate,
          filter: state.filter,
          meta: previous.meta,
          error: error.apiErrorModel.message,
        ));
      },
    );
  }

  Future<void> refreshIfStale({Duration maxAge = const Duration(minutes: 1)}) {
    if (state.isLoading || state.isRefreshing) return Future.value();
    final lastLoadedAt = _lastLoadedAt;
    if (lastLoadedAt != null &&
        DateTime.now().difference(lastLoadedAt) < maxAge) {
      return Future.value();
    }
    return load();
  }

  void selectFilter(StockTransferFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }
}
