class TripCustomersResponse {
  const TripCustomersResponse({
    required this.success,
    required this.data,
    this.message,
  });

  final bool success;
  final List<TripCustomer> data;
  final String? message;

  factory TripCustomersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return TripCustomersResponse(
      success: json['success'] == true,
      data: raw is List
          ? raw.whereType<Map>().map((item) => TripCustomer.fromJson(
                Map<String, dynamic>.from(item),
              )).toList(growable: false)
          : const <TripCustomer>[],
      message: json['message']?.toString(),
    );
  }
}

class TripCustomer {
  const TripCustomer({
    this.customerId,
    required this.name,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.ordersCount,
    required this.deliveryStatus,
  });

  final String? customerId;
  final String name;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final int ordersCount;
  final String deliveryStatus;

  factory TripCustomer.fromJson(Map<String, dynamic> json) {
    return TripCustomer(
      customerId: _value(json['customer_id']),
      name: _value(json['name']) ?? '',
      phone: _value(json['phone']) ?? '',
      address: _value(json['address']) ?? '',
      latitude: _number(json['latitude']),
      longitude: _number(json['longitude']),
      ordersCount: (num.tryParse('${json['orders_count'] ?? 0}') ?? 0).toInt(),
      deliveryStatus: _value(json['delivery_status']) ?? '',
    );
  }

  bool get hasPhone => phone.trim().isNotEmpty &&
      RegExp(r'^[+0-9\s()\-]{7,20}$').hasMatch(phone.trim());

  bool get hasLocation => latitude != null && longitude != null &&
      latitude! >= -90 && latitude! <= 90 &&
      longitude! >= -180 && longitude! <= 180;
}

String? _value(dynamic value) {
  if (value == null) return null;
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}

double? _number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
