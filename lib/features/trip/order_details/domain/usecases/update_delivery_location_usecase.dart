import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/update_delivery_location_request_body.dart';
import 'package:storeus_delivery/features/trip/order_details/domain/repo/order_details_repo_interface.dart';

class UpdateOrderDeliveryLocationUsecase {
  final OrderDetailsRepoInterface _repo;

  UpdateOrderDeliveryLocationUsecase(this._repo);

  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required UpdateDeliveryLocationBody body,
  }) {
    return _repo.updateOrderDeliveryLocation(
      tripId: tripId,
      orderId: orderId,
      body: body,
    );
  }
}
