
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/current_trip/data/models/trip_orders_response.dart';
import 'package:storeus_delivery/features/trip/current_trip/domain/repo/trip_orders_repo_interface.dart';

class GetTripOrdersUsecase {
  final TripOrdersRepoInterface _repo;

  GetTripOrdersUsecase(this._repo);

  Future<ApiResult<TripOrdersResponse>> call({
    required int tripId,
  }) async {
    return _repo.getTripOrders(tripId: tripId);
  }
}
