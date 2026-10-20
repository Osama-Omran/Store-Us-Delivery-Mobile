import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/data/models/treasury_wallet_response.dart';
import 'package:storeus_delivery/features/drawer_features/treasury/domain/repo/treasury_wallet_repo_interface.dart';

class ConcreteTreasuryWalletRepo implements TreasuryWalletRepoInterface {
  const ConcreteTreasuryWalletRepo(this._api);

  final TripApiService _api;

  @override
  Future<ApiResult<TreasuryWalletResponse>> getWallet({required int tripId}) async {
    try {
      final token = await PreferencesHelper.getToken();
      if (token == null || token.trim().isEmpty) {
        throw StateError('Access token is missing');
      }
      final response = await _api.getTripWallet(tripId, 'Bearer $token');
      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e('Get trip wallet failed', error: error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
