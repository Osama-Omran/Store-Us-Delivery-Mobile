
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/cancel_delivery/data/models/cancel_delivery_request_body.dart';

abstract class CancelDeliveryRepoInterface {
  Future<ApiResult<dynamic>> cancelDelivery({
    required int tripId,
    required int orderId,
    required CancelDeliveryRequestBody body,
  });
}
