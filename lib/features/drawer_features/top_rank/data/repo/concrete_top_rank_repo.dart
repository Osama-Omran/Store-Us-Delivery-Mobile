import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';

import 'package:storeus_delivery/features/drawer_features/top_rank/data/models/top_rank_response.dart';
import 'package:storeus_delivery/features/drawer_features/top_rank/domain/repo/top_rank_repo_interface.dart';

class ConcreteTopRankRepo implements TopRankRepoInterface {
  const ConcreteTopRankRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<TopRankResponse>> getTopRank({
    required String range,
    String? category,
    String? entity,
  }) async {
    try {
      final token = await PreferencesHelper.getToken();

      if (token == null || token.isEmpty) {
        throw StateError('Access token is missing');
      }

      final rawResponse = await _apiService.getTopRank(
        'Bearer $token',
        range,
        category,
        entity,
      );

      if (rawResponse is! Map) {
        throw const FormatException('Invalid Top Rank response');
      }

      final response = TopRankResponse.fromJson(
        Map<String, dynamic>.from(rawResponse),
      );

      if (!response.success || response.data == null) {
        throw StateError(response.message ?? 'تعذر تحميل الترتيب');
      }

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
