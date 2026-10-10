
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';

sealed class NotificationsState {}

final class NotificationsInitial extends NotificationsState {}

final class NotificationsLoadingState extends NotificationsState {}

final class NotificationsFailureState extends NotificationsState {
  final String? errorMessage;

  NotificationsFailureState(this.errorMessage);
}

final class NotificationsSuccessState extends NotificationsState {
  final List<NotificationItem> notifications;
  final int unreadCount;
  final Set<int> markingIds;

  NotificationsSuccessState({
    required this.notifications,
    required this.unreadCount,
    this.markingIds = const {},
  });

  NotificationsSuccessState copyWith({
    List<NotificationItem>? notifications,
    int? unreadCount,
    Set<int>? markingIds,
  }) {
    return NotificationsSuccessState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      markingIds: markingIds ?? this.markingIds,
    );
  }
}
