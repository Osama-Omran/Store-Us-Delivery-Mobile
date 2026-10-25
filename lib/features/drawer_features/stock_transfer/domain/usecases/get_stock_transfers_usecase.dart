import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/data/models/stock_transfers_response.dart';
import 'package:storeus_delivery/features/drawer_features/stock_transfer/domain/repo/stock_transfer_repo_interface.dart';

class GetStockTransfersUsecase {
  const GetStockTransfersUsecase(this._repository);

  final StockTransferRepoInterface _repository;

  Future<ApiResult<StockTransfersResponse>> call() => _repository.getTransfers();
}
