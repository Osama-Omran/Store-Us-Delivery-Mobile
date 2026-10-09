
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/domain/repo/receive_trip_repo_interface.dart';

class LoadedItemsUsecase {
  final ReceiveTripRepoInterface _repo;

  LoadedItemsUsecase(this._repo);

  Future<ApiResult<LoadedItemsResponse>> call({
    required int tripId,
  }) async {
    return _repo.getLoadedItems(tripId: tripId);
  }
}
