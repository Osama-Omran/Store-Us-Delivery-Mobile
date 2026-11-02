import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/change_password_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/repo/account_repo_interface.dart';

class ChangePasswordUsecase {
  final AccountRepoInterface _repo;

  ChangePasswordUsecase(this._repo);

  Future<ApiResult<dynamic>> call(
      ChangePasswordRequestBody body,
      ) {
    return _repo.changePassword(body);
  }
}