
import 'dart:io';

import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';

class ConcreteReceiveTripRepo
    implements ReceiveTripRepoInterface {
  final TripApiService _apiService;

  ConcreteReceiveTripRepo(this._apiService);

  Future<String> _getAuthorization() async {
    final token = await PreferencesHelper.getToken();

    if (token == null || token.trim().isEmpty) {
      throw StateError('Access token is missing');
    }

    return 'Bearer $token';
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

      return ApiResult.failure(
        ErrorHandler.handle(error),
      );
    }
  }

}
