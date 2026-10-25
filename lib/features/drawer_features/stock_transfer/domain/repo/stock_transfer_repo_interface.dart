import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfers_response.dart';

abstract class StockTransferRepoInterface {
  Future<ApiResult<StockTransfersResponse>> getTransfers();
}
