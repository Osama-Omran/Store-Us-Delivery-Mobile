import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/retry_collection_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';

class GetOrderDetailsUsecase {
  final OrderDetailsRepoInterface _repo;

  GetOrderDetailsUsecase(this._repo);

  /// Reuse the repository already injected into this feature; no DI changes.
  Future<ApiResult<dynamic>> retryCollection({
    required int tripId,
    required int orderId,
    required RetryCollectionRequestBody body,
  }) => _repo.retryCollection(tripId: tripId, orderId: orderId, body: body);

  Future<ApiResult<OrderDetailsResponse>> call({
    required int tripId,
    required int orderId,
  }) async {
    return _repo.getOrderDetails(tripId: tripId, orderId: orderId);
  }
}
