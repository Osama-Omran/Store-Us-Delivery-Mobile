
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.isMarking = false,
  });

  final NotificationItem notification;
  final bool isMarking;

  // ======= Notification Icon ======= //
  IconData get _icon {
    final type = notification.type.toLowerCase();

    if (type.startsWith('warehouse_transfer.')) {
      return Icons.swap_horiz_rounded;
    }

    if (type.contains('cancelled')) {
      return Icons.cancel_outlined;
    }

    if (type.contains('completed')) {
      return Icons.check_circle_outline_rounded;
    }

    if (type.startsWith('trip.')) {
      return Icons.local_shipping_outlined;
    }

    if (type.startsWith('order.')) {
      return Icons.inventory_2_outlined;
    }

    if (type.startsWith('payment.')) {
      return Icons.account_balance_wallet_outlined;
    }

    return Icons.notifications_none_rounded;
  }

  // ======= Notification Time ======= //
  String _formatTime(BuildContext context) {
    final createdAt = notification.createdAt;

    if (createdAt == null) return '—';

    final date = createdAt.toLocal();
    final difference = DateTime.now().difference(date);

    if (!difference.isNegative) {
      if (difference.inMinutes < 1) {
        return context.strings.notification_just_now;
      }

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} '
            '${context.strings.notification_minutes_ago}';
      }

      if (difference.inHours < 24) {
        return '${difference.inHours} '
            '${context.strings.notification_hours_ago}';
      }

      if (difference.inDays == 1) {
        return context.strings.yesterday;
      }
    }

    final localization = MaterialLocalizations.of(context);

    final formattedDate = localization.formatMediumDate(date);

    final formattedTime = localization.formatTimeOfDay(
      TimeOfDay.fromDateTime(date),
    );

    return '$formattedDate - $formattedTime';
  }

  // ======= Mark As Read ======= //
  Future<void> _markAsRead(BuildContext context) async {
    if (notification.isRead || isMarking) return;

    final error = await context
        .read<NotificationsCubit>()
        .markAsRead(notification.id);

    if (!context.mounted || error == null) return;

    final message = error == 'notifications_mark_read_failed'
        ? context.strings.notifications_mark_read_failed
        : error;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.red0,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    final description = notification.message.trim().isNotEmpty
        ? notification.message
        : notification.body;

    return Material(
      color: isRead ? AppColors.white0 : AppColors.blue2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(
          color: isRead ? AppColors.grey3 : AppColors.blue3,
        ),
      ),
      child: InkWell(
        onTap: isRead || isMarking
            ? null
            : () async {
          await _markAsRead(context);
        },
        borderRadius: BorderRadius.circular(26),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 112),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    // ======= Notification Icon ======= //
                    _NotificationIcon(
                      icon: _icon,
                      isRead: isRead,
                    ),

                    // ======= Notification Details ======= //
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.3,
                              color: AppColors.grey4,
                            ),
                          ),

                          Text(
                            _formatTime(context),
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

              // ======= Unread Indicator / Loading ======= //
              if (isMarking)
                PositionedDirectional(
                  end: 20,
                  top: 25,
                  child: SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (!isRead)
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

// =====================================================
// Notification Icon
// =====================================================

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
