import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
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
      final prefToken = await PreferencesHelper.getToken();
      if ((prefToken == null || prefToken.trim().isEmpty) &&
          token.isNullOrEmpty()) {
        throw StateError('Access token is missing');
      }

      final authToken = prefToken != null && prefToken.trim().isNotEmpty
          ? prefToken
          : token;
      final response = await _apiService.getReportsOverview(
        'Bearer $authToken',
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
