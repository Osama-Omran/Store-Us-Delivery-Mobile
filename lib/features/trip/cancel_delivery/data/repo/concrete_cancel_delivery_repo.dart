import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;

import 'package:storeus_delivery/features/trip/cancel_delivery/data/models/cancel_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/domain/repo/cancel_delivery_repo_interface.dart';

class ConcreteCancelDeliveryRepo implements CancelDeliveryRepoInterface {
  ConcreteCancelDeliveryRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<dynamic>> cancelDelivery({
    required int tripId,
    required int orderId,
    required CancelDeliveryRequestBody body,
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

      final response = await _apiService.cancelDelivery(
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
