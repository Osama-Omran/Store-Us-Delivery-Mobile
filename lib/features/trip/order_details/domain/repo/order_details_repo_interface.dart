
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/order_details/data/models/order_details_response.dart';

abstract class OrderDetailsRepoInterface {
  Future<ApiResult<OrderDetailsResponse>> getOrderDetails({
    required int tripId,
    required int orderId,
  });
}
