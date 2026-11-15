import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/usecases/get_vehicle_stock_usecase.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_extra_product.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';

class DeliveryDraftCubit extends Cubit<DeliveryDraftState> {
  DeliveryDraftCubit(this._getVehicleStockUsecase)
      : super(DeliveryDraftInitial());

  final GetVehicleStockUsecase _getVehicleStockUsecase;

  static DeliveryDraftCubit get(BuildContext context) =>
      BlocProvider.of<DeliveryDraftCubit>(context);

  void initialize(OrderDetailsData order) {
    if (isClosed) return;
    final currentState = state;
    // Keep user selections when the same order refreshes (e.g. address edit).
    if (currentState is DeliveryDraftReady &&
        currentState.salesOrder == order.salesOrder) {
      return;
    }

    final initialQuantities = <int, num>{};
    final temporary = DeliveryDraftReady(
      salesOrder: order.salesOrder,
      items: order.items,
      quantities: const {},
      originalTotal: order.originalTotal,
    );
    for (var i = 0; i < order.items.length; i++) {
      initialQuantities[i] = temporary.maxFor(i);
    }
    emit(DeliveryDraftReady(
      salesOrder: order.salesOrder,
      items: order.items,
      quantities: initialQuantities,
      originalTotal: order.originalTotal,
    ));
  }

  void setQuantity(int index, num value) {
    final current = state;
    if (current is! DeliveryDraftReady ||
        index < 0 || index >= current.items.length) return;

    final nextValue = value.clamp(0, current.maxFor(index));
    if (current.qtyFor(index) == nextValue) return;
    emit(current.copyWith(
      quantities: {...current.quantities, index: nextValue},
    ));
  }

  void increment(int index) {
    final current = state;
    if (current is! DeliveryDraftReady) return;
    setQuantity(index, current.qtyFor(index) + 1);
  }

  void decrement(int index) {
    final current = state;
    if (current is! DeliveryDraftReady) return;
    setQuantity(index, current.qtyFor(index) - 1);
  }

  /// Load vehicle stock from the existing trip POS options API. The server
  /// must still validate the extra_items at confirmation time.
  Future<void> loadExtraProducts(int tripId, {bool force = false}) async {
    final initial = state;
    if (isClosed || tripId <= 0 || initial is! DeliveryDraftReady ||
        initial.loadingExtraProducts ||
        (initial.extraProductsLoaded && !force)) return;

    final salesOrder = initial.salesOrder;
    emit(initial.copyWith(
      loadingExtraProducts: true,
      extraProductsLoaded: false,
      clearExtraProductsError: true,
    ));

    try {
      final result = await _getVehicleStockUsecase(tripId);
      if (isClosed) return;
      final current = state;
      if (current is! DeliveryDraftReady ||
          current.salesOrder != salesOrder) return;

      result.when(
        success: (stock) {
          if (stock.currency != 'EGP') {
            emit(current.copyWith(
              loadingExtraProducts: false,
              extraProductsError: 'currency',
            ));
            return;
          }
          if (stock.sellableItems.any(
            (item) => item.available != item.available.toInt(),
          )) {
            emit(current.copyWith(
              loadingExtraProducts: false,
              extraProductsError: 'fractional',
            ));
            return;
          }
          final products = <DeliveryExtraProduct>[
            for (final item in stock.sellableItems)
              DeliveryExtraProduct(
                itemCode: item.itemCode,
                itemName: item.itemName,
                uom: item.uom,
                availableQuantity: item.available.toInt(),
                rateMinor: item.rateMinor,
              ),
          ];
          // Keep previously selected SKUs visible even if their stock is now
          // zero. They must be explicitly removed before proceeding.
          final codes = products.map((item) => item.itemCode).toSet();
          for (final old in current.selectedExtraProducts) {
            if (!codes.contains(old.itemCode)) {
              products.add(DeliveryExtraProduct(
                itemCode: old.itemCode,
                itemName: old.itemName,
                uom: old.uom,
                availableQuantity: 0,
                rateMinor: old.rateMinor,
              ));
            }
          }
          emit(current.copyWith(
            extraProducts: products,
            extraProductsLoaded: true,
            loadingExtraProducts: false,
            clearExtraProductsError: true,
          ));
        },
        failure: (_) => emit(current.copyWith(
          loadingExtraProducts: false,
          extraProductsError: 'failed',
        )),
      );
    } catch (_) {
      if (!isClosed) {
        final current = state;
        if (current is DeliveryDraftReady &&
            current.salesOrder == salesOrder) {
          emit(current.copyWith(
            loadingExtraProducts: false,
            extraProductsError: 'failed',
          ));
        }
      }
    }
  }

  /// The picker commits all quantities atomically. Invalid/unknown SKUs are
  /// rejected rather than silently clamped to another amount.
  bool setExtraQuantities(Map<String, int> quantities) {
    final current = state;
    if (isClosed || current is! DeliveryDraftReady ||
        !current.extraProductsLoaded || current.loadingExtraProducts) {
      return false;
    }
    final byCode = {
      for (final product in current.extraProducts) product.itemCode: product,
    };
    for (final entry in quantities.entries) {
      final product = byCode[entry.key];
      if (product == null || entry.value < 0 ||
          entry.value > product.availableQuantity) return false;
    }
    emit(current.copyWith(
      extraQuantities: {
        for (final entry in quantities.entries)
          if (entry.value > 0) entry.key: entry.value,
      },
    ));
    return true;
  }
}
