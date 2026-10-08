
enum AppNotificationType {
  tripAssigned,
  tripReordered,
  orderUpdated,
  paymentReceived,
  tripCompleted,
}

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final String timeLabel;
  final AppNotificationType type;
  final bool isRead;
}
