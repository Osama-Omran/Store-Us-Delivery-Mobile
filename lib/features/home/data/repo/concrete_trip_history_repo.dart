import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';
import 'package:storeus_delivery/features/home/domain/repo/trip_history_repo_interface.dart';

class ConcreteTripHistoryRepo implements TripHistoryRepoInterface {
  final TripApiService _apiService;

  ConcreteTripHistoryRepo(this._apiService);

  @override
  Future<ApiResult<TripHistoryResponse>> getTripHistory() async {
    try {
      final prefToken = await PreferencesHelper.getToken();

      if ((prefToken == null || prefToken.trim().isEmpty) &&
          token.isNullOrEmpty()) {
        throw StateError('Access token is missing');
      }

      final authToken = prefToken != null && prefToken.trim().isNotEmpty
          ? prefToken
          : token;

      final response = await _apiService.getTripHistory('Bearer $authToken');

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.f(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
