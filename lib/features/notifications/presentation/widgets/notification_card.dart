import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
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

  // Keep the current notification-type mapping unchanged.
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

  Color get _iconColor {
    final type = notification.type.toLowerCase();
    if (type.contains('cancelled')) return AppColors.red1;
    if (type.contains('completed')) return AppColors.green0;
    return AppColors.primary;
  }

  // Keep the original relative-date behavior.
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

  // Keep the existing mark-as-read operation and error handling.
  Future<void> _markAsRead(BuildContext context) async {
    if (notification.isRead || isMarking) return;

    final error = await context.read<NotificationsCubit>().markAsRead(
      notification.id,
    );

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
    final accent = _iconColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isRead ? AppColors.white0 : AppColors.blue5,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isRead ? AppColors.grey3 : AppColors.blue3,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: isRead ? 0.02 : 0.055),
            blurRadius: isRead ? 9 : 17,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRead || isMarking ? null : () => _markAsRead(context),
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 17, 16, 17),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NotificationIcon(
                      icon: _icon,
                      iconColor: accent,
                      isRead: isRead,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.35,
                                    fontWeight:
                                        isRead ? FontWeight.w700 : FontWeight.w800,
                                    color: AppColors.black1,
                                  ),
                                ),
                              ),
                              if (isMarking) ...[
                                const SizedBox(width: 7),
                                const CustomLoadingIndicator(
                                  size: 42,
                                  primaryColor: true,
                                ),
                              ] else if (!isRead) ...[
                                const SizedBox(width: 10),
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.18),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.55,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                color: AppColors.grey4,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  _formatTime(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                PositionedDirectional(
                  start: 0,
                  top: 21,
                  bottom: 21,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(9),
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
    required this.iconColor,
    required this.isRead,
  });

  final IconData icon;
  final Color iconColor;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isRead ? AppColors.grey5 : iconColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? AppColors.grey3.withValues(alpha: 0.6)
              : iconColor.withValues(alpha: 0.12),
        ),
      ),
      child: Icon(
        icon,
        size: 25,
        color: isRead ? AppColors.grey4 : iconColor,
      ),
    );
  }
}
