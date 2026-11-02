import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/update_profile_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/change_password_request_body.dart';

abstract class AccountRepoInterface {
  Future<ApiResult<MeResponse>> getMe();

  Future<ApiResult<dynamic>> logout();

  Future<ApiResult<dynamic>> updateProfile(
      UpdateProfileRequestBody body,
      );

  Future<ApiResult<dynamic>> changePassword(
      ChangePasswordRequestBody body,
      );
}