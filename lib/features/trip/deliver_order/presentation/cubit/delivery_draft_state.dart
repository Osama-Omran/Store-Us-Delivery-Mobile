
import 'dart:math' as math;

import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

sealed class DeliveryDraftState {}

final class DeliveryDraftInitial extends DeliveryDraftState {}

final class DeliveryDraftReady extends DeliveryDraftState {
  DeliveryDraftReady({
    required this.salesOrder,
    required this.items,
    required Map<int, num> quantities,
    this.originalTotal,
  }) : quantities = Map.unmodifiable(quantities);

  final String salesOrder;
  final List<OrderDetailsItem> items;
  final Map<int, num> quantities;
  final num? originalTotal;

  // ======= Maximum Allowed Quantity ======= //
  num maxFor(int index) {
    final item = items[index];

    final ordered = item.orderedQty;
    final available = item.vehicleAvailableQty;
    final deliverable = item.maxDeliverableQty;

    // Never assume unlimited stock when data is missing.
    if (ordered == null ||
        available == null ||
        deliverable == null) {
      return 0;
    }

    final limit = math.min(
      ordered,
      math.min(available, deliverable),
    );

    if (!limit.isFinite) return 0;

    return math.max(0, limit);
  }

  num qtyFor(int index) => quantities[index] ?? 0;

  num shortfallFor(int index) {
    final ordered = items[index].orderedQty;

    if (ordered == null) return 0;

    return math.max(0, ordered - qtyFor(index));
  }

  bool hasStockShortage(int index) {
    final item = items[index];

    if (item.orderedQty == null ||
        item.vehicleAvailableQty == null) {
      return false;
    }

    return item.vehicleAvailableQty! < item.orderedQty!;
  }

  bool get hasSelectedItems {
    for (var i = 0; i < items.length; i++) {
      if (qtyFor(i) > 0) return true;
    }

    return false;
  }

  bool get isPartial {
    for (var i = 0; i < items.length; i++) {
      final ordered = items[i].orderedQty;

      if (ordered == null ||
          qtyFor(i) < ordered) {
        return true;
      }
    }

    return false;
  }

  // ======= Estimated Delivered Items Value ======= //
  num? get estimatedItemsValue {
    num total = 0;

    for (var i = 0; i < items.length; i++) {
      final quantity = qtyFor(i);

      if (quantity <= 0) continue;

      final rate = items[i].rate;

      if (rate == null || !rate.isFinite) {
        return null;
      }

      total += quantity * rate;
    }

    return total;
  }

  DeliveryDraftReady copyWith({
    Map<int, num>? quantities,
  }) {
    return DeliveryDraftReady(
      salesOrder: salesOrder,
      items: items,
      quantities: quantities ?? this.quantities,
      originalTotal: originalTotal,
    );
  }
}
