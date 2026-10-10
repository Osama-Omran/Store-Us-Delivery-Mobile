
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/presentation/cubit/delivery_draft_state.dart';

class DeliveryDraftCubit extends Cubit<DeliveryDraftState> {
  DeliveryDraftCubit() : super(DeliveryDraftInitial());

  static DeliveryDraftCubit get(BuildContext context) =>
      BlocProvider.of<DeliveryDraftCubit>(context);

  // ======= Initialize From Real API ======= //
  void initialize(OrderDetailsData order) {
    if (isClosed) return;

    final currentState = state;

    // Preserve manually selected quantities after
    // refreshing the customer's address.
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

    emit(
      DeliveryDraftReady(
        salesOrder: order.salesOrder,
        items: order.items,
        quantities: initialQuantities,
        originalTotal: order.originalTotal,
      ),
    );
  }

  // ======= Update Quantity ======= //
  void setQuantity(int index, num value) {
    final current = state;

    if (current is! DeliveryDraftReady ||
        index < 0 ||
        index >= current.items.length) {
      return;
    }

    final maximum = current.maxFor(index);
    final nextValue = value.clamp(0, maximum);

    if (current.qtyFor(index) == nextValue) return;

    emit(
      current.copyWith(
        quantities: {
          ...current.quantities,
          index: nextValue,
        },
      ),
    );
  }

  // ======= Increase Quantity ======= //
  void increment(int index) {
    final current = state;

    if (current is! DeliveryDraftReady) return;

    setQuantity(
      index,
      current.qtyFor(index) + 1,
    );
  }

  // ======= Decrease Quantity ======= //
  void decrement(int index) {
    final current = state;

    if (current is! DeliveryDraftReady) return;

    setQuantity(
      index,
      current.qtyFor(index) - 1,
    );
  }
}
