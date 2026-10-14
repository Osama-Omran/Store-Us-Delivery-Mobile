import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfers_response.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/domain/repo/stock_transfer_repo_interface.dart';

class ConcreteStockTransferRepo implements StockTransferRepoInterface {
  const ConcreteStockTransferRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<StockTransfersResponse>> getTransfers() async {
    try {
      final token = await PreferencesHelper.getToken();
      if (token == null || token.trim().isEmpty) {
        throw StateError('Access token is missing');
      }

      final response = await _apiService.getWarehouseTransfers('Bearer $token');
      if (!response.success) {
        throw StateError(response.message ?? 'Could not load transfers');
      }
      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
