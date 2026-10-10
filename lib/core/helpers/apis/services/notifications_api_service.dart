
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';

part 'notifications_api_service.g.dart';

@RestApi()
abstract class NotificationsApiService {
  factory NotificationsApiService(
      Dio dio, {
        String? baseUrl,
        ParseErrorLogger? errorLogger,
      }) = _NotificationsApiService;

  @GET(ApiConstants.notifications)
  Future<NotificationsResponse> getNotifications(
      @Header('Authorization') String authorization,
      );

  @PATCH(ApiConstants.markNotificationAsRead)
  Future<dynamic> markAsRead(
      @Path('notificationId') int notificationId,
      @Header('Authorization') String authorization,
      );
}
