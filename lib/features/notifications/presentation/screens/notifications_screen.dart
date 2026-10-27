import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:storeus_delivery/core/helpers/functions/extensions.dart';
import 'package:storeus_delivery/core/theme/app_colors.dart';
import 'package:storeus_delivery/core/widgets/custom_loading_indicator.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notification_card.dart';
import 'package:storeus_delivery/features/notifications/presentation/widgets/notifications_header.dart';
import 'package:storeus_delivery/core/theme/text_styles.dart';

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
            final unreadCount = state is NotificationsSuccessState
                ? state.unreadCount
                : null;

            return Column(
              children: [
                NotificationsHeader(unreadCount: unreadCount),
                Expanded(
                  child: switch (state) {
                    NotificationsInitial() || NotificationsLoadingState() =>
                      const _NotificationsLoadingView(),
                    NotificationsFailureState() => _NotificationsErrorView(
                      message: state.errorMessage?.isNotEmpty == true
                          ? state.errorMessage!
                          : context.strings.notifications_load_failed,
                      onRetry: () =>
                          context.read<NotificationsCubit>().getNotifications(),
                    ),
                    NotificationsSuccessState() => RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.white0,
                      onRefresh: () =>
                          context.read<NotificationsCubit>().getNotifications(),
                      child: state.notifications.isEmpty
                          ? const _NotificationsEmptyView()
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                16,
                                18,
                                16,
                                145,
                              ),
                              itemCount: state.notifications.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final notification = state.notifications[index];

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

class _NotificationsLoadingView extends StatelessWidget {
  const _NotificationsLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: Container(
          width: 168,
          height: 168,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blue5,
            border: Border.all(color: AppColors.blue4),
          ),
          child: const CustomLoadingIndicator(size: 144, primaryColor: true),
        ),
      ),
    );
  }
}

class _NotificationsEmptyView extends StatelessWidget {
  const _NotificationsEmptyView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 110),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.blue5,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blue4),
                    ),
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white0,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 37,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.strings.no_notifications,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle17.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.black1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsErrorView extends StatelessWidget {
  const _NotificationsErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 112),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 410),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 27),
          decoration: BoxDecoration(
            color: AppColors.white0,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.grey3),
            boxShadow: [
              BoxShadow(
                color: AppColors.black1.withValues(alpha: 0.035),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.red1.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 35,
                  color: AppColors.red1,
                ),
              ),
              const SizedBox(height: 19),
              Text(
                context.localizedErrorMessage(message),
                textAlign: TextAlign.center,
                style: Styles.textStyle15.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey1,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.blue5,
                    side: BorderSide(color: AppColors.blue3),
                    minimumSize: const Size(0, 49),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 21),
                  label: Text(
                    context.strings.current_trip_retry,
                    style: Styles.base.copyWith(fontWeight: FontWeight.w700),
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
