
class OrderDetailsResponse {
  final bool success;
  final OrderDetailsData? data;
  final String? message;

  const OrderDetailsResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory OrderDetailsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderDetailsResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] is Map
          ? OrderDetailsData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      )
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
    'message': message,
  };
}

class OrderDetailsData {
  final String salesOrder;
  final OrderDetailsCustomer? customer;
  final num? originalTotal;
  final List<OrderDetailsItem> items;
  final String deliveryStatus;
  final String? deliveryReason;
  final DateTime? rescheduledFor;

  const OrderDetailsData({
    required this.salesOrder,
    this.customer,
    this.originalTotal,
    required this.items,
    required this.deliveryStatus,
    this.deliveryReason,
    this.rescheduledFor,
  });

  factory OrderDetailsData.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderDetailsData(
      salesOrder: json['sales_order']?.toString() ?? '',
      customer: json['customer'] is Map
          ? OrderDetailsCustomer.fromJson(
        Map<String, dynamic>.from(json['customer'] as Map),
      )
          : null,
      originalTotal: _parseNumber(json['original_total']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (item) => OrderDetailsItem.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      deliveryStatus:
      json['delivery_status']?.toString() ?? '',
      deliveryReason: json['delivery_reason']?.toString(),
      rescheduledFor: DateTime.tryParse(
        json['rescheduled_for']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'sales_order': salesOrder,
    'customer': customer?.toJson(),
    'original_total': originalTotal,
    'items': items.map((item) => item.toJson()).toList(),
    'delivery_status': deliveryStatus,
    'delivery_reason': deliveryReason,
    'rescheduled_for': rescheduledFor?.toIso8601String(),
  };
}

class OrderDetailsCustomer {
  final String? name;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  const OrderDetailsCustomer({
    this.name,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory OrderDetailsCustomer.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderDetailsCustomer(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      latitude: _parseNumber(json['latitude'])?.toDouble(),
      longitude: _parseNumber(json['longitude'])?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class OrderDetailsItem {
  final String itemCode;
  final String itemName;
  final String uom;
  final num? orderedQty;
  final num? vehicleAvailableQty;
  final num? maxDeliverableQty;
  final num? rate;

  const OrderDetailsItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    this.orderedQty,
    this.vehicleAvailableQty,
    this.maxDeliverableQty,
    this.rate,
  });

  factory OrderDetailsItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderDetailsItem(
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      uom: json['uom']?.toString() ?? '',
      orderedQty: _parseNumber(json['ordered_qty']),
      vehicleAvailableQty:
      _parseNumber(json['vehicle_available_qty']),
      maxDeliverableQty:
      _parseNumber(json['max_deliverable_qty']),
      rate: _parseNumber(json['rate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'item_name': itemName,
    'uom': uom,
    'ordered_qty': orderedQty,
    'vehicle_available_qty': vehicleAvailableQty,
    'max_deliverable_qty': maxDeliverableQty,
    'rate': rate,
  };
}

num? _parseNumber(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
