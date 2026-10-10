
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';

class ConcreteOrderDetailsRepo
    implements OrderDetailsRepoInterface {
  final TripApiService _apiService;

  ConcreteOrderDetailsRepo(this._apiService);

  @override
  Future<ApiResult<OrderDetailsResponse>> getOrderDetails({
    required int tripId,
    required int orderId,
  }) async {
    try {
      final token = await PreferencesHelper.getToken();

      if (token == null || token.trim().isEmpty) {
        throw StateError('Access token is missing');
      }

      final response = await _apiService.getOrderDetails(
        tripId,
        orderId,
        'Bearer $token',
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
