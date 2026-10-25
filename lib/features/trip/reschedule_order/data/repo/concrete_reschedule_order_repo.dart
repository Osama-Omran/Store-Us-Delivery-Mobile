import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;

import 'package:storeus_delivery/features/trip/reschedule_order/data/models/reschedule_order_request_body.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/repo/reschedule_order_repo_interface.dart';

class ConcreteRescheduleOrderRepo implements RescheduleOrderRepoInterface {
  ConcreteRescheduleOrderRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<dynamic>> rescheduleOrder({
    required int tripId,
    required int orderId,
    required RescheduleOrderRequestBody body,
  }) async {
    try {
      final prefToken = await PreferencesHelper.getToken();

      if ((prefToken == null || prefToken.trim().isEmpty) &&
          token.isNullOrEmpty()) {
        throw StateError('Access token is missing');
      }

      final authToken = prefToken != null && prefToken.trim().isNotEmpty
          ? prefToken
          : token;

      final response = await _apiService.rescheduleOrder(
        tripId,
        orderId,
        'Bearer $authToken',
        body,
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
