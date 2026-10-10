
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';

abstract class NotificationsRepoInterface {
  Future<ApiResult<NotificationsResponse>> getNotifications();

  Future<ApiResult<dynamic>> markAsRead({
    required int notificationId,
  });
}
