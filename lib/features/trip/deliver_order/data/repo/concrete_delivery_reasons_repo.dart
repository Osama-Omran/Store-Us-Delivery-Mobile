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
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/delivery_reasons_repo_interface.dart';

class ConcreteDeliveryReasonsRepo implements DeliveryReasonsRepoInterface {
  const ConcreteDeliveryReasonsRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<DeliveryReasonsData>> getDeliveryReasons() async {
    try {
      final prefToken = await PreferencesHelper.getToken();
      if ((prefToken == null || prefToken.trim().isEmpty) &&
          token.isNullOrEmpty()) {
        throw StateError('Access token is missing');
      }
      final authToken = prefToken != null && prefToken.trim().isNotEmpty
          ? prefToken
          : token;

      final response = await _apiService.getDeliveryReasons(
        'Bearer $authToken',
      );
      final reasons = DeliveryReasonsResponse.fromJson(response);
      return ApiResult.success(reasons.data);
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
