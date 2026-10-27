import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_outcome_request_body.dart';

abstract class DeliveryOutcomeRepoInterface {
  Future<ApiResult<dynamic>> submitDeliveryOutcome({
    required int tripId,
    required int orderId,
    required DeliveryOutcomeRequestBody body,
  });
}
