import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/login/data/models/login_request_body.dart';
import 'package:storeus_delivery/features/login/data/models/login_response.dart';
import 'package:storeus_delivery/features/login/domain/repo/login_repo_interface.dart';

class LoginUsecase {
  final LoginRepoInterface _repo;

  LoginUsecase(this._repo);

  Future<ApiResult<LoginResponse>> call({
    required LoginRequestBody body,
  }) async {
    final response = await _repo.login(body);
    return response;
  }
}
