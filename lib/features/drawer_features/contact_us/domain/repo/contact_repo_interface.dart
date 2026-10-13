import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/send_support_message_body.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/support_contact_response.dart';

abstract class ContactRepoInterface {
  Future<ApiResult<SupportContactData>> getContact();

  Future<ApiResult<bool>> sendMessage(SendSupportMessageBody body);
}
