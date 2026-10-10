
class TripHistoryResponse {
  final bool success;
  final List<TripHistoryItem> data;
  final String? message;

  const TripHistoryResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory TripHistoryResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return TripHistoryResponse(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (item) => TripHistoryItem.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      if (message != null) 'message': message,
    };
  }
}

class TripHistoryItem {
  final int id;
  final String number;
  final String status;
  final DateTime? tripDate;
  final DateTime? completedAt;
  final int? totalOrders;

  const TripHistoryItem({
    required this.id,
    required this.number,
    required this.status,
    this.tripDate,
    this.completedAt,
    this.totalOrders,
  });

  factory TripHistoryItem.fromJson(
      Map<String, dynamic> json,
      ) {
    final summary = json['orders_summary'];

    return TripHistoryItem(
      id: _parseInt(json['id']) ?? 0,
      number: json['number']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      tripDate: DateTime.tryParse(
        json['trip_date']?.toString() ?? '',
      ),
      completedAt: DateTime.tryParse(
        json['completed_at']?.toString() ?? '',
      ),
      totalOrders: summary is Map
          ? _parseInt(summary['total'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status,
      'trip_date': tripDate == null
          ? null
          : '${tripDate!.year.toString().padLeft(4, '0')}-'
          '${tripDate!.month.toString().padLeft(2, '0')}-'
          '${tripDate!.day.toString().padLeft(2, '0')}',
      'completed_at': completedAt?.toUtc().toIso8601String(),
      'orders_summary': {
        'total': totalOrders,
      },
    };
  }

  String get normalizedStatus =>
      status.trim().toUpperCase();

  bool get isPreviousTrip =>
      normalizedStatus == 'COMPLETED' ||
          normalizedStatus == 'CANCELLED';

  bool isOnDate(DateTime date) {
    final value = tripDate;

    return value != null &&
        value.year == date.year &&
        value.month == date.month &&
        value.day == date.day;
  }
}

int? _parseInt(dynamic value) {
  if (value is num) return value.toInt();

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}
