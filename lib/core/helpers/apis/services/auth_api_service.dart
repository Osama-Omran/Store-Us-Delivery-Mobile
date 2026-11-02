import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/features/login/data/models/login_request_body.dart';
import 'package:storeus_delivery/features/login/data/models/login_response.dart';
import 'package:storeus_delivery/features/drawer_features/account/data/models/me_response.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _AuthApiService;

  @POST(ApiConstants.login)
  Future<LoginResponse> login(@Body() LoginRequestBody body);

  @GET(ApiConstants.me)
  Future<MeResponse> getMe(@Header('Authorization') String authorization);

  @POST(ApiConstants.logout)
  Future<dynamic> logout(@Header('Authorization') String authorization);

  @PATCH(ApiConstants.profile)
  Future<dynamic> updateProfile(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiConstants.profile)
  Future<dynamic> updateProfileWithPhoto(
    @Header('Authorization') String authorization,
    @Body() FormData body,
  );

  @POST(ApiConstants.profilePassword)
  Future<dynamic> changePassword(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );
}
