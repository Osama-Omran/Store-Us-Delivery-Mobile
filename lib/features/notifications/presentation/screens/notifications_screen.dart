import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/notifications/data/models/app_notification_model.dart';
import 'package:storeus_delivery/features/notifications/data/models/mock_notifications.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notification_card.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.notifications,
    this.onNotificationTap,
  });

  final List<AppNotificationModel>? notifications;
  final ValueChanged<AppNotificationModel>? onNotificationTap;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Set<String> _readNotificationIds = {};

  bool _isRead(AppNotificationModel notification) {
    return notification.isRead ||
        _readNotificationIds.contains(notification.id);
  }

  void _onNotificationTap(AppNotificationModel notification) {
    if (!_isRead(notification)) {
      setState(() {
        _readNotificationIds.add(notification.id);
      });
    }

    widget.onNotificationTap?.call(notification);
  }

  @override
  Widget build(BuildContext context) {
    final notifications =
        widget.notifications ?? buildMockNotifications(context);

    final unreadCount = notifications
        .where((notification) => !_isRead(notification))
        .length;

    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        child: Column(
          children: [
            NotificationsHeader(unreadCount: unreadCount),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        context.strings.no_notifications,
                        style: TextStyle(fontSize: 16, color: AppColors.grey4),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];

                        return NotificationCard(
                          notification: notification,
                          isRead: _isRead(notification),
                          onTap: () {
                            _onNotificationTap(notification);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
