
class TripOrdersResponse {
  final bool success;
  final List<TripOrderData> data;
  final String? message;

  const TripOrdersResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory TripOrdersResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return TripOrdersResponse(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => TripOrderData.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.map((item) => item.toJson()).toList(),
    if (message != null) 'message': message,
  };
}

class TripOrderData {
  final int id;
  final String salesOrder;
  final int stopOrder;
  final TripOrderCustomer? customer;
  final String? address;
  final double? latitude;
  final double? longitude;
  final num? orderTotal;
  final String deliveryStatus;
  final String paymentStatus;
  final DateTime? updatedAt;
  final int? version;

  const TripOrderData({
    required this.id,
    required this.salesOrder,
    required this.stopOrder,
    this.customer,
    this.address,
    this.latitude,
    this.longitude,
    this.orderTotal,
    required this.deliveryStatus,
    required this.paymentStatus,
    this.updatedAt,
    this.version,
  });

  factory TripOrderData.fromJson(
      Map<String, dynamic> json,
      ) {
    return TripOrderData(
      id: _toNum(json['id'])?.toInt() ?? 0,
      salesOrder: json['sales_order']?.toString() ?? '',
      stopOrder: _toNum(json['stop_order'])?.toInt() ?? 0,
      customer: json['customer'] is Map
          ? TripOrderCustomer.fromJson(
        Map<String, dynamic>.from(
          json['customer'] as Map,
        ),
      )
          : null,
      address: json['address']?.toString(),
      latitude: _toNum(json['latitude'])?.toDouble(),
      longitude: _toNum(json['longitude'])?.toDouble(),
      orderTotal: _toNum(json['order_total']),
      deliveryStatus:
      json['delivery_status']?.toString() ?? '',
      paymentStatus:
      json['payment_status']?.toString() ?? '',
      updatedAt: DateTime.tryParse(
        json['updated_at']?.toString() ?? '',
      ),
      version: _toNum(json['version'])?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sales_order': salesOrder,
    'stop_order': stopOrder,
    'customer': customer?.toJson(),
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'order_total': orderTotal,
    'delivery_status': deliveryStatus,
    'payment_status': paymentStatus,
    'updated_at': updatedAt?.toUtc().toIso8601String(),
    'version': version,
  };
}

class TripOrderCustomer {
  final String? id;
  final String? name;
  final String? phone;

  const TripOrderCustomer({
    this.id,
    this.name,
    this.phone,
  });

  factory TripOrderCustomer.fromJson(
      Map<String, dynamic> json,
      ) {
    return TripOrderCustomer(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
  };
}

num? _toNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
