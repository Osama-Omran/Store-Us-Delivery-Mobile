import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';

abstract class TripCustomersRepoInterface {
  Future<ApiResult<TripCustomersResponse>> getTripCustomers({
    required int tripId,
  });
}
