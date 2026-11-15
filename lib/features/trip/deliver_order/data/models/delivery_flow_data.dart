import 'package:storeus_delivery/features/trip/deliver_order/data/models/confirm_delivery_request_body.dart';

class DeliveryFlowItem {
  const DeliveryFlowItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.orderedQty,
    required this.selectedQty,
    this.lineId,
    this.rate,
  });

  final String? lineId;
  final String itemCode;
  final String itemName;
  final String uom;
  final num orderedQty;
  final num selectedQty;
  final num? rate;

  num get remaining => (orderedQty - selectedQty).clamp(0, orderedQty);
  bool get hasValidLineId => lineId != null && lineId!.trim().isNotEmpty;
}

/// Extra vehicle-stock item; never masquerades as an original SO line.
class DeliveryFlowExtraItem {
  const DeliveryFlowExtraItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.selectedQty,
    required this.availableQty,
    required this.rateMinor,
  });

  final String itemCode;
  final String itemName;
  final String uom;
  final int selectedQty;
  final int availableQty;
  final int rateMinor;

  num get total => selectedQty * rateMinor / 100;
}

class DeliveryFlowData {
  const DeliveryFlowData({
    required this.tripId,
    required this.orderId,
    required this.salesOrder,
    required this.customerName,
    required this.items,
    this.extraItems = const [],
    this.originalTotal,
    this.partialReason,
    this.notes,
  });

  final int tripId;
  final int orderId;
  final String salesOrder;
  final String customerName;
  final List<DeliveryFlowItem> items;
  final List<DeliveryFlowExtraItem> extraItems;
  final num? originalTotal;
  final String? partialReason;
  final String? notes;

  num get orderedQty =>
      items.fold<num>(0, (sum, item) => sum + item.orderedQty);
  num get deliveredQty =>
      items.fold<num>(0, (sum, item) => sum + item.selectedQty);
  num get remainingQty =>
      items.fold<num>(0, (sum, item) => sum + item.remaining);
  bool get isPartial => remainingQty > 0;

  bool get hasMissingLineIds =>
      items.any((item) => item.selectedQty > 0 && !item.hasValidLineId);

  bool get hasInvalidExtraItems => extraItems.any(
    (item) => item.itemCode.trim().isEmpty ||
        item.selectedQty <= 0 || item.selectedQty > item.availableQty ||
        item.rateMinor < 0,
  );

  num? get estimatedItemsValue {
    num total = 0;
    for (final item in items) {
      if (item.selectedQty <= 0) continue;
      if (item.rate == null || !item.rate!.isFinite) return null;
      total += item.rate! * item.selectedQty;
    }
    return total;
  }

  num get estimatedExtraItemsValue =>
      extraItems.fold<num>(0, (sum, item) => sum + item.total);

  num? get estimatedTotal {
    final original = estimatedItemsValue;
    if (original == null || hasInvalidExtraItems) return null;
    return original + estimatedExtraItemsValue;
  }

  List<ConfirmDeliveryItem> get apiItems => [
    for (final item in items)
      if (item.selectedQty > 0 && item.hasValidLineId)
        ConfirmDeliveryItem(
          lineId: item.lineId!,
          itemCode: item.itemCode,
          qty: item.selectedQty,
        ),
  ];

  List<ConfirmDeliveryExtraItem> get apiExtraItems => [
    for (final item in extraItems)
      if (item.selectedQty > 0)
        ConfirmDeliveryExtraItem(
          itemCode: item.itemCode,
          qty: item.selectedQty,
        ),
  ];

  DeliveryFlowData copyWith({String? partialReason, String? notes}) =>
      DeliveryFlowData(
        tripId: tripId,
        orderId: orderId,
        salesOrder: salesOrder,
        customerName: customerName,
        items: items,
        extraItems: extraItems,
        originalTotal: originalTotal,
        partialReason: partialReason ?? this.partialReason,
        notes: notes ?? this.notes,
      );
}
