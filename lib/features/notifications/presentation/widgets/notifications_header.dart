
import 'package:flutter/material.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';

class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({
    super.key,
    this.unreadCount,
  });

  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.grey0,
        border: Border(
          bottom: BorderSide(color: AppColors.grey3),
        ),
      ),
      child: Column(
        spacing: 2,
        children: [
          Text(
            context.strings.notifications,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
          if (unreadCount != null)
            Text(
              '$unreadCount '
                  '${context.strings.unread_notifications}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey4,
              ),
            ),
        ],
      ),
    );
  }
}
