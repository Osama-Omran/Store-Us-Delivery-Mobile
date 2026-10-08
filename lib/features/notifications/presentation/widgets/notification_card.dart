
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/notifications/data/models/app_notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.isRead,
    this.onTap,
  });

  final AppNotificationModel notification;
  final bool isRead;
  final VoidCallback? onTap;

  IconData get _icon {
    switch (notification.type) {
      case AppNotificationType.tripAssigned:
        return Icons.local_shipping_outlined;

      case AppNotificationType.tripReordered:
        return Icons.route_outlined;

      case AppNotificationType.orderUpdated:
        return Icons.inventory_2_outlined;

      case AppNotificationType.paymentReceived:
        return Icons.account_balance_wallet_outlined;

      case AppNotificationType.tripCompleted:
        return Icons.local_shipping_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isRead ? AppColors.white0 : AppColors.blue2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(
          color: isRead ? AppColors.grey3 : AppColors.blue3,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 112,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    _NotificationIcon(
                      icon: _icon,
                      isRead: isRead,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black1,
                            ),
                          ),
                          Text(
                            notification.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              color: AppColors.grey4,
                            ),
                          ),
                          Text(
                            notification.timeLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Unread Indicator
              if (!isRead)
                PositionedDirectional(
                  end: 20,
                  top: 27,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({
    required this.icon,
    required this.isRead,
  });

  final IconData icon;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.grey5
            : AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        size: 25,
        color: isRead
            ? AppColors.grey4
            : AppColors.white0,
      ),
    );
  }
}
