
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/data/models/cancel_delivery_request_body.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/domain/repo/cancel_delivery_repo_interface.dart';

class CancelDeliveryUsecase {
  const CancelDeliveryUsecase(this._repo);

  final CancelDeliveryRepoInterface _repo;

  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required CancelDeliveryRequestBody body,
  }) {
    return _repo.cancelDelivery(
      tripId: tripId,
      orderId: orderId,
      body: body,
    );
  }
}
