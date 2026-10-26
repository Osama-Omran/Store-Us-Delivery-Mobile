import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' as app_router;
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_request_body.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/create_customer_response.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/repo/create_customer_repo_interface.dart';

class ConcreteCreateCustomerRepo implements CreateCustomerRepoInterface {
  const ConcreteCreateCustomerRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<CreateCustomerResponse>> createCustomer(
    CreateCustomerRequestBody body,
  ) async {
    try {
      final prefToken = await PreferencesHelper.getToken();
      final globalToken = app_router.token;
      final accessToken = prefToken?.trim().isNotEmpty == true
          ? prefToken!.trim()
          : (globalToken ?? '').trim();
      if (accessToken.isEmpty) {
        throw StateError('Access token is missing');
      }

      final response = await _apiService.createCustomer(
        'Bearer $accessToken',
        body,
      );
      return ApiResult.success(response);
    } on DioException catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
