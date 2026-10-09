
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:storeus_delivery/core/helpers/apis/api_constants.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/current_trip_response.dart';
import 'package:storeus_delivery/features/trip/receive_trip/data/models/loaded_items_response.dart';

part 'trip_api_service.g.dart';

@RestApi()
abstract class TripApiService {
  factory TripApiService(
      Dio dio, {
        String? baseUrl,
        ParseErrorLogger? errorLogger,
      }) = _TripApiService;

  @GET(ApiConstants.currentTrip)
  Future<CurrentTripResponse> getCurrentTrip(
      @Header('Authorization') String authorization,
      );

  @GET(ApiConstants.loadedItems)
  Future<LoadedItemsResponse> getLoadedItems(
      @Path('tripId') int tripId,
      @Header('Authorization') String authorization,
      );


  @POST(ApiConstants.acceptTrip)
  @MultiPart()
  Future<dynamic> acceptTrip(
      @Path('tripId') int tripId,
      @Header('Authorization') String authorization,
      @Part(name: 'proof_photo') File proofPhoto,
      @Part(name: 'latitude') String latitude,
      @Part(name: 'longitude') String longitude,
      @Part(name: 'device_id') String deviceId,
      @Part(name: 'client_operation_id') String clientOperationId,
      );
}
