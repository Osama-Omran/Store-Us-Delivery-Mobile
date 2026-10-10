
class NotificationsResponse {
  final bool success;
  final NotificationsData? data;
  final String? message;

  const NotificationsResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory NotificationsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationsResponse(
      success: json['success'] == true,
      data: json['data'] is Map
          ? NotificationsData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      )
          : null,
      message: json['message']?.toString(),
    );
  }
}

class NotificationsData {
  final int unreadCount;
  final List<NotificationItem> notifications;

  const NotificationsData({
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationsData.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationsData(
      unreadCount: _toInt(json['unread_count']) ?? 0,
      notifications:
      (json['notifications'] as List<dynamic>? ?? [])
          .map(
            (item) => NotificationItem.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

class NotificationItem {
  final int id;
  final String type;
  final String severity;
  final String title;
  final String message;
  final String body;
  final int? userId;
  final String? warehouse;
  final NotificationResource? resource;
  final String? actionUrl;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final bool isRead;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.body,
    this.userId,
    this.warehouse,
    this.resource,
    this.actionUrl,
    this.data = const {},
    this.readAt,
    required this.isRead,
    this.resolvedAt,
    this.createdAt,
  });

  factory NotificationItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationItem(
      id: _toInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      userId: _toInt(json['user_id']),
      warehouse: json['warehouse']?.toString(),
      resource: json['resource'] is Map
          ? NotificationResource.fromJson(
        Map<String, dynamic>.from(
          json['resource'] as Map,
        ),
      )
          : null,
      actionUrl: json['action_url']?.toString(),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : const {},
      readAt: DateTime.tryParse(
        json['read_at']?.toString() ?? '',
      ),
      isRead: json['is_read'] == true ||
          json['read_at'] != null,
      resolvedAt: DateTime.tryParse(
        json['resolved_at']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(
        json['created_at']?.toString() ?? '',
      ),
    );
  }

  NotificationItem copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      severity: severity,
      title: title,
      message: message,
      body: body,
      userId: userId,
      warehouse: warehouse,
      resource: resource,
      actionUrl: actionUrl,
      data: data,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
    );
  }
}

class NotificationResource {
  final String? type;
  final int? id;

  const NotificationResource({
    this.type,
    this.id,
  });

  factory NotificationResource.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationResource(
      type: json['type']?.toString(),
      id: _toInt(json['id']),
    );
  }
}

int? _toInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
