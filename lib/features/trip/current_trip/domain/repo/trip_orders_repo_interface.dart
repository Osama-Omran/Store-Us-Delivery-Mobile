
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';

abstract class TripOrdersRepoInterface {
  Future<ApiResult<TripOrdersResponse>> getTripOrders({
    required int tripId,
  });
}
