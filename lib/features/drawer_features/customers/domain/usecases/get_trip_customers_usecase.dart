import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/customers/data/models/trip_customers_response.dart';
import 'package:storeus_delivery/features/drawer_features/customers/domain/repo/trip_customers_repo_interface.dart';

class GetTripCustomersUsecase {
  const GetTripCustomersUsecase(this._repo);
  final TripCustomersRepoInterface _repo;

  Future<ApiResult<TripCustomersResponse>> call({required int tripId}) =>
      _repo.getTripCustomers(tripId: tripId);
}
