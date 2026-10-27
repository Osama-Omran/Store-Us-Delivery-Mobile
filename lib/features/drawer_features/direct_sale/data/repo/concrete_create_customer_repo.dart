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
      final statusCode = error.response?.statusCode;
      // A definitive client-side rejection (e.g. 400/422 validation) means
      // the customer was NOT created. Let the user correct the form and retry
      // with a NEW idempotency key.
      // 408/409/425/429 and 5xx may be ambiguous: preserve the original
      // operation ID and request body for an explicit, safe retry.
      final definitelyRejected = statusCode != null &&
          statusCode >= 400 &&
          statusCode < 500 &&
          !const {408, 409, 425, 429}.contains(statusCode);
      if (definitelyRejected) {
        return ApiResult.success(
          CreateCustomerResponse(
            success: false,
            message: _responseErrorMessage(error.response?.data),
          ),
        );
      }
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}

// Do not expose raw HTML/error objects in a user-facing Snackbar.
String _responseErrorMessage(dynamic data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    final errors = data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty && value.first is String) {
          return (value.first as String).trim();
        }
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
  }
  return 'direct_sale_customer_create_failed';
}
