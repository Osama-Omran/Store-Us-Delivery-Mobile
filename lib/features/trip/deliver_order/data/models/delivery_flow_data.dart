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

class DeliveryFlowData {
  const DeliveryFlowData({
    required this.tripId,
    required this.orderId,
    required this.salesOrder,
    required this.customerName,
    required this.items,
    this.originalTotal,
    this.partialReason,
    this.notes,
  });

  final int tripId;
  final int orderId;
  final String salesOrder;
  final String customerName;
  final List<DeliveryFlowItem> items;
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

  num? get estimatedTotal {
    num total = 0;

    for (final item in items) {
      if (item.selectedQty <= 0) continue;

      if (item.rate == null || !item.rate!.isFinite) {
        return null;
      }

      total += item.rate! * item.selectedQty;
    }

    return total;
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

  DeliveryFlowData copyWith({String? partialReason, String? notes}) {
    return DeliveryFlowData(
      tripId: tripId,
      orderId: orderId,
      salesOrder: salesOrder,
      customerName: customerName,
      items: items,
      originalTotal: originalTotal,
      partialReason: partialReason ?? this.partialReason,
      notes: notes ?? this.notes,
    );
  }
}
