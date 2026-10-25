import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/confirm_delivery_request_body.dart';

abstract class ConfirmDeliveryRepoInterface {
  Future<ApiResult<dynamic>> confirmDelivery({
    required int tripId,
    required int orderId,
    required ConfirmDeliveryRequestBody body,
  });
}
