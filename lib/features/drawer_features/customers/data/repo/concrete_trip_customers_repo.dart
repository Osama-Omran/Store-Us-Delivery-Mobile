import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' as app_router;
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:storeus_delivery/features/drawer_features/customers/domain/repo/trip_customers_repo_interface.dart';

class ConcreteTripCustomersRepo implements TripCustomersRepoInterface {
  const ConcreteTripCustomersRepo(this._apiService);
  final TripApiService _apiService;

  @override
  Future<ApiResult<TripCustomersResponse>> getTripCustomers({
    required int tripId,
  }) async {
    try {
      final prefToken = await PreferencesHelper.getToken();
      final authToken = (prefToken?.trim().isNotEmpty ?? false)
          ? prefToken!.trim()
          : (app_router.token?.trim() ?? '');
      if (authToken.isEmpty) {
        throw StateError('Access token missing');
      }
      final response = await _apiService.getTripCustomers(
        tripId,
        'Bearer $authToken',
      );
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
