import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_model.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/delivery_outcome_repo_interface.dart';

class ConcreteDeliveryOutcomeRepo implements DeliveryOutcomeRepoInterface {
  const ConcreteDeliveryOutcomeRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<dynamic>> submitDeliveryOutcome({
    required int tripId,
    required int orderId,
    required DeliveryOutcomeRequestBody body,
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

      // Retrofit accepts a JSON map here: do NOT send Multipart/FormData.
      final response = await _apiService.submitDeliveryOutcome(
        tripId,
        orderId,
        'Bearer $authToken',
        body.toJson(),
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
