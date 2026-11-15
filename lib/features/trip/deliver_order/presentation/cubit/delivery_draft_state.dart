import 'dart:math' as math;

import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_extra_product.dart';

sealed class DeliveryDraftState {}

final class DeliveryDraftInitial extends DeliveryDraftState {}

final class DeliveryDraftReady extends DeliveryDraftState {
  DeliveryDraftReady({
    required this.salesOrder,
    required this.items,
    required Map<int, num> quantities,
    this.originalTotal,
    List<DeliveryExtraProduct> extraProducts = const [],
    Map<String, int> extraQuantities = const {},
    this.loadingExtraProducts = false,
    this.extraProductsLoaded = false,
    this.extraProductsError,
  }) : quantities = Map.unmodifiable(quantities),
       extraProducts = List.unmodifiable(extraProducts),
       extraQuantities = Map.unmodifiable(extraQuantities);

  final String salesOrder;
  final List<OrderDetailsItem> items;
  final Map<int, num> quantities;
  final num? originalTotal;

  // Extra items are separate from the original Sales Order lines.
  final List<DeliveryExtraProduct> extraProducts;
  final Map<String, int> extraQuantities;
  final bool loadingExtraProducts;
  final bool extraProductsLoaded;
  final String? extraProductsError;

  num maxFor(int index) {
    final item = items[index];
    final ordered = item.orderedQty;
    final available = item.vehicleAvailableQty;
    final deliverable = item.maxDeliverableQty;

    // Never assume unlimited stock when data is missing.
    if (ordered == null || available == null || deliverable == null) return 0;

    final limit = math.min(ordered, math.min(available, deliverable));
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
    if (item.orderedQty == null || item.vehicleAvailableQty == null) {
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
      if (ordered == null || qtyFor(i) < ordered) return true;
    }
    return false;
  }

  num? get estimatedItemsValue {
    num total = 0;
    for (var i = 0; i < items.length; i++) {
      final quantity = qtyFor(i);
      if (quantity <= 0) continue;
      final rate = items[i].rate;
      if (rate == null || !rate.isFinite) return null;
      total += quantity * rate;
    }
    return total;
  }

  int extraQtyFor(DeliveryExtraProduct product) =>
      extraQuantities[product.itemCode] ?? 0;

  List<DeliveryExtraProduct> get selectedExtraProducts =>
      extraProducts.where((product) => extraQtyFor(product) > 0).toList();

  bool get hasExtraProducts => extraQuantities.values.any((qty) => qty > 0);

  /// If stock has changed after refresh, never silently reduce the cart.
  /// The user must explicitly adjust any now-invalid quantity.
  bool get extraQuantitiesValid {
    if (!hasExtraProducts) return true;
    if (!extraProductsLoaded) return false;
    final byCode = {for (final item in extraProducts) item.itemCode: item};
    for (final entry in extraQuantities.entries) {
      if (entry.value <= 0) continue;
      final product = byCode[entry.key];
      if (product == null || entry.value > product.availableQuantity) {
        return false;
      }
    }
    return true;
  }

  num? get estimatedExtraProductsValue {
    if (!extraQuantitiesValid) return null;
    int totalMinor = 0;
    for (final product in selectedExtraProducts) {
      totalMinor += product.rateMinor * extraQtyFor(product);
    }
    return totalMinor / 100;
  }

  num? get estimatedTotal {
    final itemsTotal = estimatedItemsValue;
    final extrasTotal = estimatedExtraProductsValue;
    if (itemsTotal == null || extrasTotal == null) return null;
    return itemsTotal + extrasTotal;
  }

  DeliveryDraftReady copyWith({
    Map<int, num>? quantities,
    List<DeliveryExtraProduct>? extraProducts,
    Map<String, int>? extraQuantities,
    bool? loadingExtraProducts,
    bool? extraProductsLoaded,
    String? extraProductsError,
    bool clearExtraProductsError = false,
  }) => DeliveryDraftReady(
    salesOrder: salesOrder,
    items: items,
    quantities: quantities ?? this.quantities,
    originalTotal: originalTotal,
    extraProducts: extraProducts ?? this.extraProducts,
    extraQuantities: extraQuantities ?? this.extraQuantities,
    loadingExtraProducts: loadingExtraProducts ?? this.loadingExtraProducts,
    extraProductsLoaded: extraProductsLoaded ?? this.extraProductsLoaded,
    extraProductsError: clearExtraProductsError
        ? null
        : extraProductsError ?? this.extraProductsError,
  );
}
