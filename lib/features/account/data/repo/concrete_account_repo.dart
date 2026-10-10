
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/auth_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/features/account/data/models/me_response.dart';
import 'package:storeus_delivery/features/account/domain/repo/account_repo_interface.dart';

class ConcreteAccountRepo implements AccountRepoInterface {
  final AuthApiService _apiService;

  ConcreteAccountRepo(this._apiService);

  Future<String> _getAuthorization() async {
    final token = await PreferencesHelper.getToken();

    if (token == null || token.trim().isEmpty) {
      throw StateError('Access token is missing');
    }

    return 'Bearer $token';
  }

  @override
  Future<ApiResult<MeResponse>> getMe() async {
    try {
      final response = await _apiService.getMe(
        await _getAuthorization(),
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(
        ErrorHandler.handle(error),
      );
    }
  }

  @override
  Future<ApiResult<dynamic>> logout() async {
    try {
      final response = await _apiService.logout(
        await _getAuthorization(),
      );

      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.e(error);

      return ApiResult.failure(
        ErrorHandler.handle(error),
      );
    }
  }
}
