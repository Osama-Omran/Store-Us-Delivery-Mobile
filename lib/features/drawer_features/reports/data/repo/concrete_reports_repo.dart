import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/drawer_features/reports/data/models/reports_models.dart';
import 'package:storeus_delivery/features/drawer_features/reports/domain/repo/reports_repo_interface.dart';

class ConcreteReportsRepo implements ReportsRepoInterface {
  const ConcreteReportsRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<ReportsData>> getOverview({
    required String from,
    required String to,
  }) async {
    try {
      final token = await PreferencesHelper.getToken();
      if (token == null || token.trim().isEmpty) {
        throw StateError('Access token is missing');
      }
      final response = await _apiService.getReportsOverview(
        'Bearer $token',
        from,
        to,
      );
      return ApiResult.success(ReportsData.fromJson(response));
    } catch (error) {
      CustomLogger.logger?.e(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
