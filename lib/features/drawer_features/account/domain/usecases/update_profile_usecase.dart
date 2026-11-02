import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/update_profile_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/repo/account_repo_interface.dart';

class UpdateProfileUsecase {
  final AccountRepoInterface _repo;

  UpdateProfileUsecase(this._repo);

  Future<ApiResult<dynamic>> call(
      UpdateProfileRequestBody body,
      ) {
    return _repo.updateProfile(body);
  }
}