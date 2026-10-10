
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/account/domain/repo/account_repo_interface.dart';

class GetMeUsecase {
  final AccountRepoInterface _repo;

  GetMeUsecase(this._repo);

  Future<ApiResult<MeResponse>> call() async {
    return _repo.getMe();
  }
}
