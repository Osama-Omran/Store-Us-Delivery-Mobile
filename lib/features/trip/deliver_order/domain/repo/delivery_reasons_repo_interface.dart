import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';

abstract class DeliveryReasonsRepoInterface {
  Future<ApiResult<DeliveryReasonsData>> getDeliveryReasons();
}
