import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_model.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';

import 'package:storeus_delivery/features/trip/deliver_order/data/models/confirm_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/confirm_delivery_repo_interface.dart';

class ConcreteConfirmDeliveryRepo implements ConfirmDeliveryRepoInterface {
  const ConcreteConfirmDeliveryRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<dynamic>> confirmDelivery({
    required int tripId,
    required int orderId,
    required ConfirmDeliveryRequestBody body,
  }) async {
    try {
      final token = await PreferencesHelper.getToken();

      if (token == null || token.trim().isEmpty) {
        throw StateError('Access token is missing');
      }

      final response = await _apiService.confirmDelivery(
        tripId,
        orderId,
        'Bearer $token',
        body,
      );

      return ApiResult.success(response);
    } on DioException catch (error) {
      CustomLogger.logger?.e(error);

      final handler = ErrorHandler.handle(error);
      final data = error.response?.data;

      if (data is Map) {
        final message = data['message']?.toString().trim();

        if (message != null && message.isNotEmpty) {
          handler.apiErrorModel = ApiErrorModel(
            message: message,
            errorCode: error.response?.statusCode,
          );
        }
      }

      return ApiResult.failure(handler);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
