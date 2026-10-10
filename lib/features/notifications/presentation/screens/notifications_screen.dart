
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notification_card.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_header.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationsScreenBody();
  }
}

class _NotificationsScreenBody extends StatelessWidget {
  const _NotificationsScreenBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey0,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final unreadCount =
            state is NotificationsSuccessState
                ? state.unreadCount
                : null;

            return Column(
              children: [
                // ======= Header ======= //
                NotificationsHeader(
                  unreadCount: unreadCount,
                ),

                // ======= Content ======= //
                Expanded(
                  child: switch (state) {
                    NotificationsInitial() ||
                    NotificationsLoadingState() =>
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                    NotificationsFailureState() =>
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 16,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 45,
                                  color: AppColors.grey4,
                                ),

                                Text(
                                  state.errorMessage?.isNotEmpty == true
                                      ? state.errorMessage!
                                      : context.strings
                                      .notifications_load_failed,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.grey4,
                                  ),
                                ),

                                OutlinedButton.icon(
                                  onPressed: () {
                                    context
                                        .read<NotificationsCubit>()
                                        .getNotifications();
                                  },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(
                                    context.strings.current_trip_retry,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                    NotificationsSuccessState() =>
                        RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => context
                              .read<NotificationsCubit>()
                              .getNotifications(),
                          child: state.notifications.isEmpty
                              ? ListView(
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Text(
                                  context.strings.no_notifications,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey4,
                                  ),
                                ),
                              ),
                            ],
                          )
                              : ListView.separated(
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              24,
                              20,
                              24,
                              145,
                            ),
                            itemCount: state.notifications.length,
                            separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notification =
                              state.notifications[index];

                              return NotificationCard(
                                key: ValueKey(notification.id),
                                notification: notification,
                                isMarking: state.markingIds.contains(
                                  notification.id,
                                ),
                              );
                            },
                          ),
                        ),

                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
