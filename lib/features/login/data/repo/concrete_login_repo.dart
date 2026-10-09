import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/auth_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/features/login/data/models/login_request_body.dart';
import 'package:storeus_delivery/features/login/data/models/login_response.dart';
import 'package:storeus_delivery/features/login/domain/repo/login_repo_interface.dart';

class ConcreteLoginRepo implements LoginRepoInterface {
  final AuthApiService _apiService;
  ConcreteLoginRepo(this._apiService);

  @override
  Future<ApiResult<LoginResponse>> login(LoginRequestBody body) async {
    try {
      final response = await _apiService.login(body);
      return ApiResult.success(response);
    } catch (error) {
      CustomLogger.logger?.f(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
