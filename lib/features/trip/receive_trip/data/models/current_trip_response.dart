class CurrentTripResponse {
  final bool success;
  final CurrentTripData? data;
  final String? message;

  const CurrentTripResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory CurrentTripResponse.fromJson(Map<String, dynamic> json) {
    return CurrentTripResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] is Map
          ? CurrentTripData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data?.toJson(),
        if (message != null) 'message': message,
      };
}

class CurrentTripData {
  final int id;
  final String number;
  final String status;
  final TripWarehouse? warehouse;
  final TripVehicle? vehicle;
  final TripDriver? driver;
  final TripAcceptance? acceptance;
  final TripOrdersSummary? ordersSummary;

  const CurrentTripData({
    required this.id,
    required this.number,
    required this.status,
    this.warehouse,
    this.vehicle,
    this.driver,
    this.acceptance,
    this.ordersSummary,
  });

  factory CurrentTripData.fromJson(Map<String, dynamic> json) {
    return CurrentTripData(
      id: (json['id'] as num).toInt(),
      number: json['number'] as String,
      status: json['status'] as String,
      warehouse: json['warehouse'] is Map
          ? TripWarehouse.fromJson(
              Map<String, dynamic>.from(json['warehouse'] as Map),
            )
          : null,
      vehicle: json['vehicle'] is Map
          ? TripVehicle.fromJson(
              Map<String, dynamic>.from(json['vehicle'] as Map),
            )
          : null,
      driver: json['driver'] is Map
          ? TripDriver.fromJson(
              Map<String, dynamic>.from(json['driver'] as Map),
            )
          : null,
      acceptance: json['acceptance'] is Map
          ? TripAcceptance.fromJson(
              Map<String, dynamic>.from(json['acceptance'] as Map),
            )
          : null,
      ordersSummary: json['orders_summary'] is Map
          ? TripOrdersSummary.fromJson(
              Map<String, dynamic>.from(json['orders_summary'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'status': status,
        'warehouse': warehouse?.toJson(),
        'vehicle': vehicle?.toJson(),
        'driver': driver?.toJson(),
        'acceptance': acceptance?.toJson(),
        'orders_summary': ordersSummary?.toJson(),
      };
}

class TripWarehouse {
  final String? id;
  final String? name;
  final String? latitude;
  final String? longitude;

  const TripWarehouse({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
  });

  factory TripWarehouse.fromJson(Map<String, dynamic> json) {
    return TripWarehouse(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class TripVehicle {
  final String? id;
  final String? name;

  const TripVehicle({this.id, this.name});

  factory TripVehicle.fromJson(Map<String, dynamic> json) {
    return TripVehicle(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class TripDriver {
  final String? id;
  final String? name;

  const TripDriver({this.id, this.name});

  factory TripDriver.fromJson(Map<String, dynamic> json) {
    return TripDriver(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class TripAcceptance {
  final String status;
  final DateTime? acceptedAt;

  const TripAcceptance({
    required this.status,
    this.acceptedAt,
  });

  factory TripAcceptance.fromJson(Map<String, dynamic> json) {
    return TripAcceptance(
      status: json['status']?.toString() ?? '',
      acceptedAt: DateTime.tryParse(json['accepted_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'accepted_at': acceptedAt?.toUtc().toIso8601String(),
      };
}

class TripOrdersSummary {
  final int total;

  const TripOrdersSummary({required this.total});

  factory TripOrdersSummary.fromJson(Map<String, dynamic> json) {
    return TripOrdersSummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'total': total};
}
