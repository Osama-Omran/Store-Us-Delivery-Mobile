import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import '../../data/models/vehicle_stock_response.dart';
import '../repo/vehicle_stock_repo_interface.dart';

class GetVehicleStockUsecase {
  const GetVehicleStockUsecase(this._repo);

  final VehicleStockRepoInterface _repo;

  Future<ApiResult<VehicleStockData>> call(int tripId) =>
      _repo.getVehicleStock(tripId);
}
