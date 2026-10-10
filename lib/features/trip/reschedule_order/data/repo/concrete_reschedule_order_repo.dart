
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';

import 'package:storeus_delivery/features/trip/reschedule_order/data/models/reschedule_order_request_body.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/repo/reschedule_order_repo_interface.dart';

class ConcreteRescheduleOrderRepo
    implements RescheduleOrderRepoInterface {
  ConcreteRescheduleOrderRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<dynamic>> rescheduleOrder({
    required int tripId,
    required int orderId,
    required RescheduleOrderRequestBody body,
  }) async {
    try {
      final token = await PreferencesHelper.getToken();

      if (token == null || token.trim().isEmpty) {
        throw StateError('Access token is missing');
      }

      final response = await _apiService.rescheduleOrder(
        tripId,
        orderId,
        'Bearer $token',
        body,
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
