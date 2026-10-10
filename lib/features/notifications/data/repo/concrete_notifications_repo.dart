
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/notifications_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/notifications/data/models/notifications_response.dart';
import 'package:storeus_delivery/features/notifications/domain/repo/notifications_repo_interface.dart';

class ConcreteNotificationsRepo
    implements NotificationsRepoInterface {
  final NotificationsApiService _apiService;

  ConcreteNotificationsRepo(this._apiService);

  Future<String> _getAuthorization() async {
    final token = await PreferencesHelper.getToken();

    if (token == null || token.trim().isEmpty) {
      throw StateError('Access token is missing');
    }

    return 'Bearer $token';
  }

  @override
  Future<ApiResult<NotificationsResponse>> getNotifications() async {
    try {
      final response = await _apiService.getNotifications(
        await _getAuthorization(),
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(
        ErrorHandler.handle(error),
      );
    }
  }

  @override
  Future<ApiResult<dynamic>> markAsRead({
    required int notificationId,
  }) async {
    try {
      final response = await _apiService.markAsRead(
        notificationId,
        await _getAuthorization(),
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(
        ErrorHandler.handle(error),
      );
    }
  }
}
