/// Immutable request: reuse this exact body and operation_id on ambiguous retry.
/// The backend accepts a single existing customer for the documented route.
class SubmitPosRequestBody {
  SubmitPosRequestBody({
    required this.operationId,
    required this.customerId,
    required List<SubmitPosItem> items,
    required this.amountMinor,
  }) : items = List.unmodifiable(items) {
    if (customerId.isEmpty || items.isEmpty || amountMinor <= 0) {
      throw ArgumentError('Invalid POS checkout');
    }
    if (items.any((item) => item.qty <= 0 || item.rateMinor < 0)) {
      throw ArgumentError('Invalid POS item quantity or rate');
    }
    final total = items.fold<int>(
      0, (sum, item) => sum + item.qty * item.rateMinor,
    );
    if (total != amountMinor) {
      throw ArgumentError('POS checkout amount does not match items');
    }
  }

  final String operationId;
  final String customerId;
  final List<SubmitPosItem> items;
  final int amountMinor;

  Map<String, dynamic> toJson() => {
    'operation_id': operationId,
    'customer_mode': 'existing',
    'customer_id': customerId,
    'items': items.map((item) => item.toJson()).toList(growable: false),
    'amount': amountMinor / 100,
  };
}

class SubmitPosItem {
  const SubmitPosItem({
    required this.itemCode,
    required this.qty,
    required this.rateMinor,
  });

  final String itemCode;
  final int qty;
  final int rateMinor;

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'qty': qty,
    'rate': rateMinor / 100,
  };
}

class SubmitPosResponse {
  const SubmitPosResponse({required this.success, this.message});

  final bool success;
  final String? message;

  factory SubmitPosResponse.fromJson(Map<String, dynamic> json) =>
      SubmitPosResponse(
        // Never show a sale as complete without explicit server confirmation.
        success: json['success'] == true,
        message: json['message'] is String ? json['message'] as String : null,
      );
}
