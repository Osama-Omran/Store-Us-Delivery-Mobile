
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';
import 'package:storeus_delivery/features/home/domain/repo/trip_history_repo_interface.dart';

class ConcreteTripHistoryRepo
    implements TripHistoryRepoInterface {
  final TripApiService _apiService;

  ConcreteTripHistoryRepo(this._apiService);

  @override
  Future<ApiResult<TripHistoryResponse>> getTripHistory() async {
    try {
      final token = await PreferencesHelper.getToken();

      if (token == null || token.trim().isEmpty) {
        throw StateError('Access token is missing');
      }

      final response = await _apiService.getTripHistory(
        'Bearer $token',
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
