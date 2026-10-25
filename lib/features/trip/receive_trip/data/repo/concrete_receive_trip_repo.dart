import 'dart:io';

import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';

class ConcreteReceiveTripRepo implements ReceiveTripRepoInterface {
  final TripApiService _apiService;

  ConcreteReceiveTripRepo(this._apiService);

  Future<String> _getAuthorization() async {
    final prefToken = await PreferencesHelper.getToken();

    if ((prefToken == null || prefToken.trim().isEmpty) &&
        token.isNullOrEmpty()) {
      throw StateError('Access token is missing');
    }

    final authToken = prefToken != null && prefToken.trim().isNotEmpty
        ? prefToken
        : token;

    return 'Bearer $authToken';
  }

  @override
  Future<ApiResult<CurrentTripResponse>> getCurrentTrip() async {
    try {
      final response = await _apiService.getCurrentTrip(
        await _getAuthorization(),
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<LoadedItemsResponse>> getLoadedItems({
    required int tripId,
  }) async {
    try {
      final response = await _apiService.getLoadedItems(
        tripId,
        await _getAuthorization(),
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> acceptTrip({
    required int tripId,
    required File photo,
    required double latitude,
    required double longitude,
    required String deviceId,
    required String clientOperationId,
  }) async {
    try {
      final response = await _apiService.acceptTrip(
        tripId,
        await _getAuthorization(),
        photo,
        latitude.toString(),
        longitude.toString(),
        deviceId,
        clientOperationId,
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.f(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
