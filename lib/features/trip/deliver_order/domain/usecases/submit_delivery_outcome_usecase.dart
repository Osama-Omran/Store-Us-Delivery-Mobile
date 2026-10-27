import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/delivery_outcome_repo_interface.dart';

class SubmitDeliveryOutcomeUsecase {
  const SubmitDeliveryOutcomeUsecase(this._repo);

  final DeliveryOutcomeRepoInterface _repo;

  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required DeliveryOutcomeRequestBody body,
  }) {
    return _repo.submitDeliveryOutcome(
      tripId: tripId,
      orderId: orderId,
      body: body,
    );
  }
}
