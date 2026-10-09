
import 'dart:io';

import 'package:storeus_delivery/core/helpers/apis/api_result.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';

abstract class ReceiveTripRepoInterface {
  Future<ApiResult<CurrentTripResponse>> getCurrentTrip();

  Future<ApiResult<LoadedItemsResponse>> getLoadedItems({
    required int tripId,
  });


  Future<ApiResult<dynamic>> acceptTrip({
    required int tripId,
    required File photo,
    required double latitude,
    required double longitude,
    required String deviceId,
    required String clientOperationId,
  });
}
