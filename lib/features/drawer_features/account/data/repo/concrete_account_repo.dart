import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/auth_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/domain/repo/account_repo_interface.dart';

class ConcreteAccountRepo implements AccountRepoInterface {
  final AuthApiService _apiService;

  ConcreteAccountRepo(this._apiService);

  Future<String> _getAuthorization() async {
    final prefToken = await PreferencesHelper.getToken();

    if ((prefToken == null || prefToken.trim().isEmpty) &&
        token.isNullOrEmpty()) {
      throw StateError('Access token is missing');
    }

    final authToken = prefToken != null && prefToken.trim().isNotEmpty
        ? prefToken
        : token;

    return 'Bearer $authToken';
  }

  @override
  Future<ApiResult<MeResponse>> getMe() async {
    try {
      final response = await _apiService.getMe(await _getAuthorization());

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> logout() async {
    try {
      final response = await _apiService.logout(await _getAuthorization());

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
