import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_response.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/repo/create_customer_repo_interface.dart';

class CreateCustomerUsecase {
  const CreateCustomerUsecase(this._repository);
  final CreateCustomerRepoInterface _repository;

  Future<ApiResult<CreateCustomerResponse>> call(
    CreateCustomerRequestBody body,
  ) => _repository.createCustomer(body);
}
