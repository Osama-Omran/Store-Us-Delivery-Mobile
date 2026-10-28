import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/repo/customer_options_repo_interface.dart';

class GetCustomerOptionsUsecase {
  const GetCustomerOptionsUsecase(this._repository);

  final CustomerOptionsRepoInterface _repository;

  Future<ApiResult<List<String>>> call() => _repository.getTerritories();
}
