import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/login/data/models/login_request_body.dart';
import 'package:storeus_delivery/features/login/data/models/login_response.dart';

abstract class LoginRepoInterface {
  Future<ApiResult<LoginResponse>> login(LoginRequestBody body);
}
