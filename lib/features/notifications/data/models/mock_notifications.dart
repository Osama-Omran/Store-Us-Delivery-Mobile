
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/features/notifications/data/models/app_notification_model.dart';

List<AppNotificationModel> buildMockNotifications(
    BuildContext context,
    ) {
  return [
    AppNotificationModel(
      id: '1',
      type: AppNotificationType.tripAssigned,
      title: context.strings.notification_new_trip_title,
      description:
      context.strings.notification_new_trip_description,
      timeLabel: context.strings.two_hours_ago,
      isRead: false,
    ),
    AppNotificationModel(
      id: '2',
      type: AppNotificationType.tripReordered,
      title: context.strings.notification_route_updated_title,
      description:
      context.strings.notification_route_updated_description,
      timeLabel: context.strings.one_hour_ago,
      isRead: false,
    ),
    AppNotificationModel(
      id: '3',
      type: AppNotificationType.orderUpdated,
      title: context.strings.notification_order_updated_title,
      description:
      context.strings.notification_order_updated_description,
      timeLabel: context.strings.forty_five_minutes_ago,
      isRead: true,
    ),
    AppNotificationModel(
      id: '4',
      type: AppNotificationType.paymentReceived,
      title: context.strings.notification_payment_received_title,
      description:
      context.strings.notification_payment_received_description,
      timeLabel: context.strings.yesterday,
      isRead: true,
    ),
    AppNotificationModel(
      id: '5',
      type: AppNotificationType.tripCompleted,
      title: context.strings.notification_trip_completed_title,
      description:
      context.strings.notification_trip_completed_description,
      timeLabel: context.strings.yesterday,
      isRead: true,
    ),
  ];
}
