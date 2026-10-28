import 'package:dio/dio.dart';
import 'package:storeus_delivery/core/helpers/apis/api_error_handler.dart';
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/core/helpers/apis/services/trip_api_service.dart';
import 'package:storeus_delivery/core/helpers/utils/preferences_helper.dart';
import 'package:storeus_delivery/core/routing/app_router.dart' as app_router;
import 'package:storeus_delivery/features/drawer_features/direct_sale/data/models/customer_options_response.dart';
import 'package:storeus_delivery/features/drawer_features/direct_sale/domain/repo/customer_options_repo_interface.dart';

class ConcreteCustomerOptionsRepo implements CustomerOptionsRepoInterface {
  const ConcreteCustomerOptionsRepo(this._apiService);

  final TripApiService _apiService;

  @override
  Future<ApiResult<List<String>>> getTerritories() async {
    try {
      final storedToken = await PreferencesHelper.getToken();
      final token = storedToken?.trim().isNotEmpty == true
          ? storedToken!.trim()
          : (app_router.token ?? '').trim();
      if (token.isEmpty) throw StateError('Access token is missing');

      // Respect the pagination supplied by /customers/options.
      final territories = <String>[];
      final seen = <String>{};
      var page = 1;
      while (true) {
        final raw = await _apiService.getCustomerOptions(
          'Bearer $token',
          page == 1 ? null : page,
        );
        if (raw is! Map) {
          throw const FormatException('Invalid customer options response');
        }
        final response = CustomerOptionsResponse.fromJson(
          Map<String, dynamic>.from(raw),
        );
        if (response.page != page) {
          throw const FormatException('Unexpected customer options page');
        }
        for (final territory in response.territories) {
          if (seen.add(territory)) territories.add(territory);
        }
        if (!response.hasMore) break;
        page++;
        if (page > 100) {
          throw const FormatException('Too many customer options pages');
        }
      }
      return ApiResult.success(List.unmodifiable(territories));
    } on DioException catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }
}
