
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';
import 'package:storeus_delivery/features/home/domain/repo/trip_history_repo_interface.dart';

class GetTripHistoryUsecase {
  final TripHistoryRepoInterface _repo;

  GetTripHistoryUsecase(this._repo);

  Future<ApiResult<TripHistoryResponse>> call() async {
    return _repo.getTripHistory();
  }
}
