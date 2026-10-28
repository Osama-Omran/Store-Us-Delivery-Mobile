import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import '../../data/models/vehicle_stock_response.dart';

abstract class VehicleStockRepoInterface {
  Future<ApiResult<VehicleStockData>> getVehicleStock(int tripId);
}
