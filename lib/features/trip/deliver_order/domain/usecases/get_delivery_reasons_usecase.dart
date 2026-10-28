import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/deliver_order/data/models/delivery_reasons_response.dart';
import 'package:storeus_delivery/features/trip/deliver_order/domain/repo/delivery_reasons_repo_interface.dart';

class GetDeliveryReasonsUsecase {
  const GetDeliveryReasonsUsecase(this._repo);

  final DeliveryReasonsRepoInterface _repo;

  Future<ApiResult<DeliveryReasonsData>> call() => _repo.getDeliveryReasons();
}
