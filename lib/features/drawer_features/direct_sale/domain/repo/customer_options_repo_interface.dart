import 'package:storeus_delivery/core/helpers/apis/api_result.dart';

abstract class CustomerOptionsRepoInterface {
  Future<ApiResult<List<String>>> getTerritories();
}
