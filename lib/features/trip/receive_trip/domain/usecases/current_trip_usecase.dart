import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';

class CurrentTripUsecase {
  final ReceiveTripRepoInterface _repo;

  CurrentTripUsecase(this._repo);

  Future<ApiResult<CurrentTripResponse>> call() async {
    return _repo.getCurrentTrip();
  }
}
