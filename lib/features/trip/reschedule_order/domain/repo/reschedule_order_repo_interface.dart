
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/data/models/reschedule_order_request_body.dart';

abstract class RescheduleOrderRepoInterface {
  Future<ApiResult<dynamic>> rescheduleOrder({
    required int tripId,
    required int orderId,
    required RescheduleOrderRequestBody body,
  });
}
