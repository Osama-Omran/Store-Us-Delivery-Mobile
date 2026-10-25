import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/functions/extensions.dart'
    show StringExtension;
import 'package:storeus_delivery/core/helpers/utils/logger.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' show token;
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/send_support_message_body.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/data/models/support_contact_response.dart';
import 'package:storeus_delivery/features/drawer_features/contact_us/domain/repo/contact_repo_interface.dart';

class ConcreteContactRepo implements ContactRepoInterface {
  const ConcreteContactRepo(this._apiService);

  final TripApiService _apiService;

  Future<String> _authorization() async {
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
  Future<ApiResult<SupportContactData>> getContact() async {
    try {
      final response = await _apiService.getSupportContact(
        await _authorization(),
      );

      if (!response.success || response.data == null) {
        throw StateError(response.message ?? 'Contact is unavailable');
      }

      return ApiResult.success(response.data!);
    } catch (error) {
      CustomLogger.logger?.e(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<bool>> sendMessage(SendSupportMessageBody body) async {
    try {
      final response = await _apiService.sendSupportMessage(
        await _authorization(),
        body,
      );

      // Retrofit/Dio throws on non-2xx responses. The successful response
      // schema was not supplied; reject only explicit API-level failures.
      if (response is Map && response['success'] == false) {
        throw StateError(
          response['message']?.toString() ?? 'Message was not sent',
        );
      }

      return const ApiResult.success(true);
    } catch (error) {
      CustomLogger.logger?.e(error);
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
