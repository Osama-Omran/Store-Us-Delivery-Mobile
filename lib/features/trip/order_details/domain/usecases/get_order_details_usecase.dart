
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';

class GetOrderDetailsUsecase {
  final OrderDetailsRepoInterface _repo;

  GetOrderDetailsUsecase(this._repo);

  Future<ApiResult<OrderDetailsResponse>> call({
    required int tripId,
    required int orderId,
  }) async {
    return _repo.getOrderDetails(
      tripId: tripId,
      orderId: orderId,
    );
  }
}
