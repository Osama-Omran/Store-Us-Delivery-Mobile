import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/send_support_message_body.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/domain/repo/contact_repo_interface.dart';

class SendSupportMessageUsecase {
  const SendSupportMessageUsecase(this._repo);

  final ContactRepoInterface _repo;

  Future<ApiResult<bool>> call(SendSupportMessageBody body) =>
      _repo.sendMessage(body);
}
