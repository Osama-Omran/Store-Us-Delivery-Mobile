
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/account/domain/repo/account_repo_interface.dart';

class LogoutUsecase {
  final AccountRepoInterface _repo;

  LogoutUsecase(this._repo);

  Future<ApiResult<dynamic>> call() async {
    return _repo.logout();
  }
}
