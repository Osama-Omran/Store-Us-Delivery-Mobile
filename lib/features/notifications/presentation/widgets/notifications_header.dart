import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.select<NotificationsCubit, int?>(
      (cubit) => cubit.state is NotificationsSuccessState
          ? (cubit.state as NotificationsSuccessState).unreadCount
          : null,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white0,
        border: Border(
          bottom: BorderSide(color: AppColors.grey3.withValues(alpha: 0.85)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [AppColors.primary, AppColors.blue0],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.white0,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.strings.notifications,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle23.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
                if (unreadCount != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    context.strings.notifications_unread_count(unreadCount),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.textStyle12_5.copyWith(
                      height: 1.25,
                      color: AppColors.grey4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (unreadCount != null && unreadCount > 0) ...[
            const SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.blue2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue3),
              ),
              child: Text(
                '$unreadCount',
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
