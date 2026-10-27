import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/dio/dio_factory.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/retry_collection_request_body.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/update_delivery_location_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';

import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_model.dart';

class ConcreteOrderDetailsRepo implements OrderDetailsRepoInterface {
  final TripApiService _apiService;

  ConcreteOrderDetailsRepo(this._apiService);

  /// IMPORTANT: Collection requests are deliberately not opted into the
  /// generic offline outbox. A timed-out payment is ambiguous until the server
  /// confirms its status. The API must deduplicate the original operation ID.
  @override
  Future<ApiResult<dynamic>> retryCollection({
    required int tripId,
    required int orderId,
    required RetryCollectionRequestBody body,
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
      final dio = await DioFactory.getDio();
      final response = await dio.post<dynamic>(
        '/trips/$tripId/orders/$orderId/retry-collection',
        data: body.toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );
      return ApiResult.success(response.data);
    } on DioException catch (error) {
      CustomLogger.logger?.e(error);
      final handler = ErrorHandler.handle(error);
      final responseData = error.response?.data;
      if (responseData is Map) {
        final message = responseData['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          handler.apiErrorModel = ApiErrorModel(
            message: message,
            errorCode: error.response?.statusCode,
          );
        }
      } else if (error.response == null) {
        handler.apiErrorModel = ApiErrorModel(
          message: 'order_collection_connection_uncertain',
        );
      }
      return ApiResult.failure(handler);
    } catch (error) {
      CustomLogger.logger?.e(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<OrderDetailsResponse>> getOrderDetails({
    required int tripId,
    required int orderId,
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

      final response = await _apiService.getOrderDetails(
        tripId,
        orderId,
        'Bearer $authToken',
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> updateOrderDeliveryLocation({
    required int tripId,
    required int orderId,
    required UpdateDeliveryLocationBody body,
  }) async {
    try {
      final response = await _apiService.updateOrderDeliveryLocation(
        tripId,
        orderId,
        'Bearer ${await PreferencesHelper.getToken()}',
        body,
      );

      return ApiResult.success(response);
    } on DioException catch (error) {
      CustomLogger.logger?.e(error);

      final handler = ErrorHandler.handle(error);
      final responseData = error.response?.data;

      // Preserve the backend message, including HTTP 5xx errors.
      if (responseData is Map) {
        final message = responseData['message']?.toString().trim();

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
