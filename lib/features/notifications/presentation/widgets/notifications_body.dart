import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notification_card.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_empty_view.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_error_view.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_shimmer.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (previous, current) {
        if (previous is NotificationsSuccessState &&
            current is NotificationsSuccessState) {
          return previous.notifications != current.notifications;
        }
        return true;
      },
      builder: (context, state) {
        return switch (state) {
          NotificationsInitial() ||
          NotificationsLoadingState() => const NotificationsShimmer(),
          NotificationsFailureState() => const NotificationsErrorView(),
          NotificationsSuccessState() => RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.white0,
            onRefresh: () => NotificationsCubit.get(context).getNotifications(),
            child: state.notifications.isEmpty
                ? const NotificationsEmptyView()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      18,
                      16,
                      145,
                    ),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = state.notifications[index];
                      return NotificationCard(
                        key: ValueKey(notification.id),
                        notification: notification,
                      );
                    },
                  ),
          ),
        };
      },
    );
  }
}
