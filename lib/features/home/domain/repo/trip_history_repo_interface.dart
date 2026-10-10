
import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/home/data/models/trip_history_response.dart';

abstract class TripHistoryRepoInterface {
  Future<ApiResult<TripHistoryResponse>> getTripHistory();
}
