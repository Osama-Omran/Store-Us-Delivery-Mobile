import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_response.dart';

abstract class CreateCustomerRepoInterface {
  Future<ApiResult<CreateCustomerResponse>> createCustomer(
    CreateCustomerRequestBody body,
  );
}
