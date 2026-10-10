
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/account/data/models/me_response.dart';

abstract class AccountRepoInterface {
  Future<ApiResult<MeResponse>> getMe();

  Future<ApiResult<dynamic>> logout();
}
