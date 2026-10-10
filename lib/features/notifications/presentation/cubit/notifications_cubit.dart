
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

import 'package:storeus_delivery/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:storeus_delivery/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:storeus_delivery/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUsecase _getNotificationsUsecase;
  final MarkNotificationAsReadUsecase _markAsReadUsecase;

  NotificationsCubit(
      this._getNotificationsUsecase,
      this._markAsReadUsecase,
      ) : super(NotificationsInitial());

  static NotificationsCubit get(BuildContext context) =>
      BlocProvider.of<NotificationsCubit>(context);

  // ======= Get Notifications ======= //
  Future<void> getNotifications() async {
    if (isClosed || state is NotificationsLoadingState) {
      return;
    }

    // Avoid overwriting pending read operations.
    final currentState = state;

    if (currentState is NotificationsSuccessState &&
        currentState.markingIds.isNotEmpty) {
      return;
    }

    emit(NotificationsLoadingState());

    final result = await _getNotificationsUsecase.call();

    if (isClosed) return;

    result.when(
      success: (response) {
        if (!response.success || response.data == null) {
          emit(
            NotificationsFailureState(response.message),
          );
          return;
        }

        emit(
          NotificationsSuccessState(
            notifications: response.data!.notifications,
            unreadCount: response.data!.unreadCount,
          ),
        );
      },
      failure: (error) {
        emit(
          NotificationsFailureState(
            error.apiErrorModel.message,
          ),
        );
      },
    );
  }

  // ======= Mark Notification As Read ======= //
  Future<String?> markAsRead(int notificationId) async {
    if (isClosed) return null;

    final currentState = state;

    if (currentState is! NotificationsSuccessState ||
        currentState.markingIds.contains(notificationId)) {
      return null;
    }

    final notificationIndex = currentState.notifications
        .indexWhere((item) => item.id == notificationId);

    if (notificationIndex == -1) return null;

    final notification =
    currentState.notifications[notificationIndex];

    if (notification.isRead) return null;

    // Mark only this card as loading.
    emit(
      currentState.copyWith(
        markingIds: {
          ...currentState.markingIds,
          notificationId,
        },
      ),
    );

    final result = await _markAsReadUsecase.call(
      notificationId: notificationId,
    );

    if (isClosed) return null;

    final latestState = state;

    if (latestState is! NotificationsSuccessState) {
      return null;
    }

    String? errorMessage;

    result.when(
      success: (response) {
        // Response is dynamic.
        if (response is Map && response['success'] == false) {
          errorMessage =
              response['message']?.toString() ??
                  'notifications_mark_read_failed';
        }
      },
      failure: (error) {
        errorMessage =
        error.apiErrorModel.message.isNotEmpty
            ? error.apiErrorModel.message
            : 'notifications_mark_read_failed';
      },
    );

    final updatedMarkingIds = {
      ...latestState.markingIds,
    }..remove(notificationId);

    // ======= Failure ======= //
    if (errorMessage != null) {
      emit(
        latestState.copyWith(
          markingIds: updatedMarkingIds,
        ),
      );

      return errorMessage;
    }

    // ======= Success ======= //
    final wasUnread = latestState.notifications.any(
          (item) => item.id == notificationId && !item.isRead,
    );

    final updatedNotifications = latestState.notifications
        .map(
          (item) => item.id == notificationId
          ? item.copyWith(isRead: true)
          : item,
    )
        .toList();

    final updatedUnreadCount = wasUnread &&
        latestState.unreadCount > 0
        ? latestState.unreadCount - 1
        : latestState.unreadCount;

    emit(
      latestState.copyWith(
        notifications: updatedNotifications,
        unreadCount: updatedUnreadCount,
        markingIds: updatedMarkingIds,
      ),
    );

    return null;
  }
}
