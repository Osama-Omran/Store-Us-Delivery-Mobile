import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/support_contact_response.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/domain/repo/contact_repo_interface.dart';

class GetSupportContactUsecase {
  const GetSupportContactUsecase(this._repo);

  final ContactRepoInterface _repo;

  Future<ApiResult<SupportContactData>> call() => _repo.getContact();
}
