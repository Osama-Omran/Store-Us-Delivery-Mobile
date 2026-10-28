import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' as app_router;

import '../models/vehicle_stock_response.dart';
import '../../domain/repo/vehicle_stock_repo_interface.dart';

class ConcreteVehicleStockRepo implements VehicleStockRepoInterface {
  const ConcreteVehicleStockRepo(this._service);

  final TripApiService _service;

  @override
  Future<ApiResult<VehicleStockData>> getVehicleStock(int tripId) async {
    try {
      if (tripId <= 0) throw ArgumentError.value(tripId, 'tripId');
      final stored = await PreferencesHelper.getToken();
      final token = stored?.trim().isNotEmpty == true
          ? stored!.trim()
          : (app_router.token ?? '').trim();
      if (token.isEmpty) throw StateError('Access token is missing');

      final response = await _service.getPosOptions(tripId, 'Bearer $token');
      return ApiResult.success(response.data);
    } on DioException catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
