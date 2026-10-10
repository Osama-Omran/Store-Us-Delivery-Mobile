
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/data/models/reschedule_order_request_body.dart';
import 'package:storeus_delivery/features/trip/reschedule_order/domain/repo/reschedule_order_repo_interface.dart';

class RescheduleOrderUsecase {
  RescheduleOrderUsecase(this._repo);

  final RescheduleOrderRepoInterface _repo;

  Future<ApiResult<dynamic>> call({
    required int tripId,
    required int orderId,
    required RescheduleOrderRequestBody body,
  }) {
    return _repo.rescheduleOrder(
      tripId: tripId,
      orderId: orderId,
      body: body,
    );
  }
}
