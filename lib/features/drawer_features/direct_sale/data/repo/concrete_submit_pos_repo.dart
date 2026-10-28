import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' as app_router;
import '../../domain/repo/submit_pos_repo_interface.dart';
import '../models/submit_pos_request_body.dart';

class ConcreteSubmitPosRepo implements SubmitPosRepoInterface {
  const ConcreteSubmitPosRepo(this._service);
  final TripApiService _service;

  @override
  Future<ApiResult<SubmitPosResponse>> submitPos(
    int tripId,
    SubmitPosRequestBody request,
  ) async {
    try {
      if (tripId <= 0) throw ArgumentError.value(tripId, 'tripId');
      final stored = await PreferencesHelper.getToken();
      final token = stored?.trim().isNotEmpty == true
          ? stored!.trim()
          : (app_router.token ?? '').trim();
      if (token.isEmpty) throw StateError('Access token is missing');

      final payload = await _service.submitPos(
        tripId,
        'Bearer $token',
        request,
      );
      if (payload is! Map) {
        throw const FormatException('Invalid POS confirmation response');
      }
      final response = SubmitPosResponse.fromJson(
        Map<String, dynamic>.from(payload),
      );
      return ApiResult.success(response);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      // Validation/permission errors are definite rejections. Network errors,
      // timeouts, rate limits and 5xx are ambiguous and MUST reuse operation_id.
      final definitiveRejection = status != null &&
          status >= 400 && status < 500 &&
          !const {408, 409, 425, 429}.contains(status);
      if (definitiveRejection) {
        return ApiResult.success(SubmitPosResponse(
          success: false,
          message: _safeMessage(error.response?.data),
        ));
      }
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}

String? _safeMessage(dynamic data) {
  if (data is! Map) return null;
  final message = data['message'];
  if (message is String && message.trim().isNotEmpty &&
      !message.contains('<')) return message.trim();
  final errors = data['errors'];
  if (errors is Map) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty && value.first is String) {
        return (value.first as String).trim();
      }
    }
  }
  return null;
}
