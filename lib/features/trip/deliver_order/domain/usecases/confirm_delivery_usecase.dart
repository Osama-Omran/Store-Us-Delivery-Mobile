import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/confirm_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/confirm_delivery_repo_interface.dart';

class ConfirmDeliveryUsecase {
  const ConfirmDeliveryUsecase(this._repo);

  final ConfirmDeliveryRepoInterface _repo;

  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required ConfirmDeliveryRequestBody body,
  }) {
    return _repo.confirmDelivery(tripId: tripId, orderId: orderId, body: body);
  }
}
