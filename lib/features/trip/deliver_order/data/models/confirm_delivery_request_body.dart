class ConfirmDeliveryRequestBody {
  const ConfirmDeliveryRequestBody({
    required this.clientOperationId,
    required this.items,
    required this.extraItems,
    required this.collectedAmount,
    required this.paymentMethod,
  });

  final String clientOperationId;
  final List<ConfirmDeliveryItem> items;
  final List<ConfirmDeliveryExtraItem> extraItems;
  final num? collectedAmount;
  final String? paymentMethod;

  Map<String, dynamic> toJson() => {
    'client_operation_id': clientOperationId,
    'items': items.map((e) => e.toJson()).toList(),
    'extra_items': extraItems.map((e) => e.toJson()).toList(),
    'collected_amount': collectedAmount,
    'payment_method': paymentMethod,
  };
}

class ConfirmDeliveryItem {
  const ConfirmDeliveryItem({
    required this.lineId,
    required this.itemCode,
    required this.qty,
  });

  final String lineId;
  final String itemCode;
  final num qty;

  Map<String, dynamic> toJson() => {
    'line_id': lineId,
    'item_code': itemCode,
    'qty': qty,
  };
}

class ConfirmDeliveryExtraItem {
  const ConfirmDeliveryExtraItem({required this.itemCode, required this.qty});

  final String itemCode;
  final num qty;

  Map<String, dynamic> toJson() => {'item_code': itemCode, 'qty': qty};
}
